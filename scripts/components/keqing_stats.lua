local function onSprintDirty(self, enabled) end
local onTailDirty = function(self, enabled) end
local SourceModifierList = require("util/sourcemodifierlist")
local CRIT_BASE = 0.05
local CRITDMG_BASE = 1.884
local BONUS_BASE = 1
local ENERGY_RECHARGE_BASE = 1.0
--- 该组件管理语音 台词等的东西以及一些行为相关的开关等，当然包括classified
-- 顺便统一管理一些rpc和本地设置的东西吧，原本的太傻x了
-- 变量同步在keqing_classified里面
local Keqing = Class(
	function(self, inst)
		self.inst = inst
		self.sprint = false
		self.isSoundEnabled = true
		-- 这个配置要提供个选项，在本地加载进入时读取本地设置给服务器发送rpc设置是否启用
		self.tail = false

		self.hascrit = false
		self.crit = SourceModifierList(self.inst, CRIT_BASE, SourceModifierList.additive)
		self.critdmg = SourceModifierList(self.inst, CRITDMG_BASE, SourceModifierList.additive)
		self.bonus = SourceModifierList(self.inst, BONUS_BASE, SourceModifierList.additive)
		self.energy_recharge = SourceModifierList(self.inst, ENERGY_RECHARGE_BASE, SourceModifierList.additive)
	end,
	nil,
	{
		-- 这里原则上只用来向本地同步
		sprint = onSprintDirty,
		tail = onTailDirty,
	}
)
function Keqing:OnLoad(data)
	if data ~= nil then
		self.sprint = data.sprint or false
		self.isSoundEnabled = data.isSoundEnabled or true
		self.tail = data.tail or false
	end
	self:EnableTail(self.tail)
end
function Keqing:EnableSprint(enable) end

function Keqing:EnableTail(enabled)
	if enabled then
		local player = self.inst
		player.tail_task = player:DoTaskInTime(2, function() -- 拖尾
			player.kq_tailing = SpawnPrefab("kq_tailing_fx")
			if player.kq_tailing ~= nil then
				player.kq_tailing_offset = -105
				player.kq_tailing.entity:AddFollower()
				player.kq_tailing.entity:SetParent(player.entity)
				player.kq_tailing.Follower:FollowSymbol(player.GUID, "swap_body", 0, player.kq_tailing_offset or 0, 0)
			end
		end)
	else
		self.inst.tail_task = nil
	end
end

function Keqing:GetDamageBonus()
	if math.random() <= self.crit:Get() and TUNING_KEQING.CRIT then
		self.hascrit = true
		return self.bonus:Get() * self.critdmg:Get()
	end
	self.hascrit = false
	return self.bonus:Get()
end
--- 非得把两个customdmgfn分开，神经
--- 不是保险方案，但是兼容性来说应该是最好的了
function Keqing:GetSpDamageBonus()
	if self.hascrit == true then
		return self.bonus:Get() * self.critdmg:Get()
	end
	return self.bonus:Get()
end

-- 范围伤害写的sm难用
-- 都做成范围伤害，range 倍率 武器好像就这样
--是否为有效目标
local function IsValidVictim(victim)
	return victim ~= nil
		and not victim:IsInLimbo()
		and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or victim:HasTag("veggie") or victim:HasTag(
			"structure"
		) or victim:HasTag("wall") or victim:HasTag("balloon") or victim:HasTag("groundspike") or victim:HasTag(
			"smashable"
		) or victim:HasTag("abigail") or victim:HasTag("companion"))
		and victim.components.combat ~= nil
		and not (victim.components.health ~= nil and victim.components.health:IsDead())
end
local AREAATTACK_MUST_TAGS = { "_combat", "_health" }
local exclude_tags =
	{ "INLIMBO", "companion", "wall", "abigail", "player", "structure", "flight", "invisible", "notarget", "noattack" }

function Keqing:DoAoeAttack(skill_mult, range, x, y, z, weapon)
	if weapon == nil then
		weapon = self.inst.components.combat:GetWeapon()
	end
	-- 处理电击伤害----[[  ]]
	local stimuli = nil
	if stimuli == nil then
		if weapon and weapon.components.weapon then
			if weapon.components.weapon.overridestimulifn then
				stimuli = weapon.components.weapon.overridestimulifn(weapon, self.inst, targ)
			end
			if stimuli == nil and weapon.components.weapon.stimuli == "electric" then
				stimuli = "electric"
			end
		end
		if stimuli == nil and self.inst.components.electricattacks ~= nil then
			stimuli = "electric"
		end
	end
	if range == nil then
		range = 10
	end
	local targets = TheSim:FindEntities(x, y, z, range, AREAATTACK_MUST_TAGS, exclude_tags)
	for _, target in ipairs(targets) do
		-- // 处理电击伤害，默认带电，对于电击免疫的目标不处理
		if IsValidVictim(target) then
			local mult = 1
			local _weapon_cmp = weapon ~= nil and weapon.components.weapon or nil
			if
				(stimuli == "electric" or (_weapon_cmp ~= nil and _weapon_cmp.stimuli == "electric"))
				and not (
					target:HasTag("electricdamageimmune")
					or (target.components.inventory ~= nil and target.components.inventory:IsInsulated())
				)
			then
				local electric_damage_mult = _weapon_cmp ~= nil and _weapon_cmp.electric_damage_mult
					or TUNING.ELECTRIC_DAMAGE_MULT
				local electric_wet_damage_mult = _weapon_cmp ~= nil and _weapon_cmp.electric_wet_damage_mult
					or TUNING.ELECTRIC_WET_DAMAGE_MULT
				mult = electric_damage_mult
					+ electric_wet_damage_mult
						* (target.components.moisture ~= nil and target.components.moisture:GetMoisturePercent() or (target:GetIsWet() and 1 or 0))
			end
			local dmg, spdmg = self.inst.components.combat:CalcDamage(target, weapon, mult * skill_mult)

			if weapon ~= nil and weapon.components.projectile == nil and target:IsValid() then
				self.inst:PushEvent("onattackother", {
					target = target,
					weapon = weapon,
					projectile = nil,
					stimuli = stimuli,
				})
			end
			target.components.combat:GetAttacked(self.inst, dmg, weapon, stimuli, spdmg)
		end

		-- 这里要做额外的判断，投射物不能推送这些时间，否则容易出问题，另外可能要加cd或者频率限制
		-- klei这个onattackother推送有毛病，感觉只能做cd
		-- if data.weapon ~= nil and data.projectile == nil
		--                 and (data.weapon.components.projectile ~= nil
	end
end

return Keqing
