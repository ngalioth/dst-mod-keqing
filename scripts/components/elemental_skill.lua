local function onCurrentCdChange(self, current_cd)
	self.inst.replica.elemental_skill:SetCurrentCd(current_cd)
end
local function onStateChange(self, state)
	self.inst.replica.elemental_skill:SetState(state)
end

-- 该组件管理战技的cd、能量、冷却时间、技能等级，管理雷楔，下线应当消失重置状态的
local Elemental_Skill = Class(
	function(self, inst)
		self.inst = inst
		self.curren_stiletto = nil -- 存储雷楔的ins引用，仅在state为true时有效
		self.skill_cd = 7.5 -- 默认冷却时间 7.5s 释放state进入2,5s内释放第二段，否则直接转回状态0，雷楔失效 当然可选引爆直接转回状态0
		self.current_cd = 0.0 -- 当前冷却时间
		self.state = false -- 技能状态 处理二段战技 不进行保存
	end,
	nil,
	{
		current_cd = onCurrentCdChange, -- 技能剩余cd
		state = onStateChange, -- 特殊状态 仅true false
	}
)
function Elemental_Skill:OnSave()
	return {
		current_cd = self.current_cd,
	}
end
function Elemental_Skill:OnLoad(data)
	if data ~= nil then
		self.current_cd = data.current_cd or self.skill_cd
		self.current_energy = data.current_energy or self.current_energy
		if self.current_cd > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
end
function Elemental_Skill:OnUpdate(dt)
	self.current_cd = self.current_cd - dt
	if self.current_cd <= 2.5 then
		self.state = false -- 二段状态失效，进入cd
	end
	if self.current_cd <= 0 then
		self.current_cd = 0
		self.inst:StopUpdatingComponent(self)
	end
end
function Elemental_Skill:StartCd()
	self.current_cd = self.skill_cd
	self.inst:StartUpdatingComponent(self)
end
function Elemental_Skill:DoSkill()
	local thunder_wedge_damage = 50.0 / 100
	local slash_damage = 168 / 100
	local thunderstorm_slash_damage = 84 / 100

	local thunder_wedge_range = 2

	local slash_range = 2
	local thunderstorm_slash_range = 10

	local range = 2
	if self.state == false and self.current_stiletto == nil then
		local stiletto = SpawnPrefab("leixie")
		stiletto.entity:SetParent(self.inst.entity)
		self.current_stiletto = stiletto
		self.state = true
		self:StartCd()
		local pos = self.inst:GetPosition()
		stiletto.Transform:SetPosition(pos.x, pos.y, pos.z)
		self.inst.components.keqing_aoe_dmg:DoAoeAttack(thunder_wedge_damage, thunder_wedge_range, pos.x, pos.y, pos.z)
	end
	if self.state == true and self.current_stiletto ~= nil then
		local stiletto = self.current_stiletto
		self.current_stiletto = nil
		self.state = false
		local target_pos = stiletto:GetPosition()
		if self.inst.Physics then
			stiletto:Remove()
			self.inst.Physics:Teleport(target_pos.x, target_pos.y, target_pos.z)
			local fx = SpawnPrefab("kq_skill_fx")
			fx.Transform:SetPosition(target_pos.x, target_pos.y, target_pos.z)
			self.inst.components.keqing_aoe_dmg:DoAoeAttack(
				slash_damage,
				slash_range,
				target_pos.x,
				target_pos.y,
				target_pos.z
			)
			self.state = false
		end
	end
end
