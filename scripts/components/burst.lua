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
		-- 由于饥荒的网络同步频率只有15hz，而dt更新的频率是30hz，过高的频率会导致变量乱序，对于cd这种很依赖顺序的需要稍微调慢点
		self._tickrate = 0
		-- 字段和网络变量名保持同步
		self.level = 1 -- 默认等级
		self.maxcd = 12.0 -- 默认冷却时间
		self.maxenergy = 40.0 -- 默认最大能量
		self.cd = 0.0 -- 当前冷却时间
		self.energy = 0.0 -- 当前能量
		makereadonly(self, "maxcd")
		makereadonly(self, "maxenergy")
	end,
	nil,
	{
		level = function(self, value, old)
			SetValue(self, "level", value)
		end,
		maxcd = function(self, value)
			SetValue(self, "maxcd", value)
		end,
		cd = function(self, value)
			self._tickrate = self._tickrate + 1
			if value <= 0 or self._tickrate >= 3 then
				self._tickrate = 0
				SetValue(self, "cd", value)
			end
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
-- 留给未来的如雷
function Burst:DoCdDelta(value)
	modassert(type(value) == "number", "value must be a number")
	if value == nil then
		return
	end
	self.cd = math.max(0, self.cd - value)
end

function Burst:DoEnergyDelta(value)
	modassert(type(value) == "number", "value must be a number")
	if self.energy >= value then
		self.energy = math.min(self.energy - value, self.maxenergy)
		return true
	end
	return false
end

function Burst:SetLevel(level)
	modassert(type(level) == "number", "level must be a number")
	local temp = (math.floor(level) - 1) % 15 + 1
	self.level = temp
end

function Burst:DoSkill(stage)
	-- 一段斩击
	local skill_dmg_mult = TUNING_KEQING.BURST_MULT_DATE[self.level].skill_damage / 100
	local slash_dmg_mult = TUNING_KEQING.BURST_MULT_DATE[self.level].slash_damage / 100 / 8
	local last_dmg_mult = TUNING_KEQING.BURST_MULT_DATE[self.level].final_hit_damage / 100
	local range = TUNING_KEQING.BURST_RANGE
	--- 8次连斩
	--- 最后一段斩击
	local x, y, z = self.inst.Transform:GetWorldPosition()
	if stage == "skill" then
		-- 这里大概加个转变鱼肉吧
		self.inst.components.keqing_stats:DoAoeAttack(skill_dmg_mult, range, x, y, z)
	elseif stage == "slash" then
		self.inst.components.keqing_stats:DoAoeAttack(slash_dmg_mult, range, x, y, z)
	elseif stage == "last" then
		self.inst.components.keqing_stats:DoAoeAttack(last_dmg_mult, range, x, y, z)
	end
end
function Burst:TryDoSkill()
	local doer = self.inst
	local canDo = doer
		and doer:IsValid()
		and doer.components.health
		and not doer.components.health:IsDead()
		and not doer.sg:HasStateTag("busy")
		and not (doer.components.rider and doer.components.rider:IsRiding())
	if not TUNING_KEQING.DEBUG then
		canDo = canDo and self:DoEnergyDelta(self.maxenergy) and self.cd <= 0
		self:SetCd()
	end
	if canDo then
		modprint("ready to do burst")
		doer:PushEvent("do_burst")
		self.inst.SoundEmitter:PlaySound("keqing_audio/keqing/battle_skill03")
	end
end

return Burst
