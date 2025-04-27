local Keqing_AOE_DMG = Class(function(self, inst)
	self.inst = inst
end)
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

function Keqing_AOE_DMG:DoAoeAttack(skill_mult, range, x, y, z, weapon)
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
return Keqing_AOE_DMG
