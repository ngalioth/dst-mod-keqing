-- 下线其实保存能量和技能等级就可以了，cd都太短了，没啥意义
--- 数据存储在主要组件完成，改动时通知classified
local function SetValue(self, name, value)
	if self.inst.keqing_classified ~= nil then
		self.inst.keqing_classified[name]:set(value)
	end
end

local function on_burst_level_dirty(self, value)
	SetValue(self, "burst_level", value)
end
local function on_burst_cd_dirty(self, value)
	SetValue(self, "burst_cd", value)
end
local function on_burst_current_cd_dirty(self, value)
	SetValue(self, "burst_current_cd", value)
end
local function on_burst_energy_dirty(self, value)
	SetValue(self, "burst_energy", value)
end
local function on_burst_current_energy_dirty(self, value)
	SetValue(self, "burst_current_energy", value)
end

local Elemental_Burst = Class(
	function(self, inst)
		self.inst = inst
		-- 字段和网络变量名保持同步
		self.burst_level = 1 -- 默认等级
		self.burst_cd = 12.0 -- 默认冷却时间
		self.burst_energy = 40.0 -- 默认最大能量
		self.burst_current_cd = 0.0 -- 当前冷却时间
		self.burst_current_energy = 0.0 -- 当前能量
	end,
	nil,
	{
		burst_level = on_burst_level_dirty,
		burst_cd = on_burst_cd_dirty,
		burst_current_cd = on_burst_current_cd_dirty,
		burst_energy = on_burst_energy_dirty,
		burst_current_energy = on_burst_current_energy_dirty,
	}
)

function Elemental_Burst:OnSave()
	return {
		current_cd = self.burst_current_cd,
		current_energy = self.burst_current_energy,
		level = self.burst_level,
	}
end
function Elemental_Burst:OnLoad(data)
	if data ~= nil then
		self.burst_cd = data.cd or 12
		self.burst_energy = data.energy or 40

		self.burst_current_cd = data.current_cd or 0
		self.burst_current_energy = data.current_energy or 12
		self.burst_level = data.level or 1
		if self.burst_current_cd > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
end
function Elemental_Burst:OnUpdate(dt)
	self.burst_current_cd = math.max(0, self.burst_current_cd - dt)
	if self.burst_current_cd == 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function Elemental_Burst:SetSkillCd(cd)
	self.burst_current_cd = cd or self.burst_cd
	self.inst:StartUpdatingComponent(self)
end

function Elemental_Burst:DoSkill(stage)
	-- 一段斩击
	local skill_dmg_mult = 1.87
	local slash_dmg_mult = 0.51
	local last_dmg_mult = 4.01
	local range = 10
	--- 8次连斩
	--- 最后一段斩击
	local x, y, z = self.inst.Transform:GetWorldPosition()
	if stage == "skill" then
		-- 这里大概加个转变鱼肉吧
		self.inst.components.keqing_aoe_dmg:DoAoeAttack(skill_dmg_mult, range, x, y, z)
	elseif stage == "slash" then
		self.inst.components.keqing_aoe_dmg:DoAoeAttack(slash_dmg_mult, range, x, y, z)
	elseif stage == "last" then
		self.inst.components.keqing_aoe_dmg:DoAoeAttack(last_dmg_mult, range, x, y, z)
	end
end

return Elemental_Burst
