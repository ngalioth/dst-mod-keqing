-- 下线其实保存能量和技能等级就可以了，cd都太短了，没啥意义
--- 数据存储在主要组件完成，改动时通知classified
local function SetValue(self, name, value)
	self.inst:PushEvent("burst_" .. name .. "_delta", value)
	if self.inst.keqing_classified ~= nil then
		self.inst.keqing_classified["burst_" .. name]:set(value)
	end
end

local Burst = Class(
	function(self, inst)
		self.inst = inst
		-- 字段和网络变量名保持同步
		self.level = 1 -- 默认等级
		self.maxcd = 12.0 -- 默认冷却时间
		self.maxenergy = 40.0 -- 默认最大能量
		self.cd = 0.0 -- 当前冷却时间
		self.energy = 0.0 -- 当前能量
	end,
	nil,
	{
		level = function(self, value)
			SetValue(self, "level", value)
		end,
		maxcd = function(self, value)
			SetValue(self, "maxcd", value)
		end,
		cd = function(self, value)
			SetValue(self, "cd", value)
		end,
		maxenergy = function(self, value)
			SetValue(self, "maxenergy", value)
		end,
		energy = function(self, value)
			SetValue(self, "energy", value)
		end,
	}
)

function Burst:OnSave()
	return {
		cd = self.cd,
		energy = self.energy,
		level = self.level,
	}
end
function Burst:OnLoad(data)
	if data ~= nil then
		self.maxcd = data.maxcd or 12
		self.cd = data.cd or 0
		self.maxenergy = data.maxenergy or 40
		self.energy = data.energy or 0
		self.level = data.level or 1
		if self.cd > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
end
function Burst:OnUpdate(dt)
	self.cd = math.max(0, self.cd - dt)
	if self.cd == 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function Burst:SetCd(cd)
	self.cd = cd or self.maxcd
	self.inst:StartUpdatingComponent(self)
end

function Burst:DoSkill(stage)
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

return Burst
