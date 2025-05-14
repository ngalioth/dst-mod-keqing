---------------------------------------------------
local function NoPlayersOrHoles(pt)
	return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end
--- 首先直接检查目标位置
--- 再目标附件搜索 这个设定半径，半径设定不会太大，防止过于夸张的平移
---
--- 那么再按照当前位置往目标位置搜索最近的可以站立的位置

local function FindPlantform(pos, target_pos)
	-- 检查

	-- 搜索

	-- 搜索位移位置
	return target_pos
end

---------------------------------------------------
local function makeDirty(self, name, value)
	local inst = self.inst
	modassert(inst ~= nil, "inst is nil")
	if inst then
		inst:PushEvent("skill_" .. name .. "_delta", value)
		local classified = inst.keqing_classified
		if classified and classified["skill_" .. name] then
			classified["skill_" .. name]:set(value)
		end
	end
end
-- 该组件管理战技的cd、能量、冷却时间、技能等级，管理雷楔，下线应当消失重置状态的
-- 战技释
-- 第一段
-- 二段 位移，战技，移除雷楔
-- 引爆 移除雷楔，造成伤害
-- 没释放进入cd雷楔需要移除，状态需要清空

local Skill = Class(
	function(self, inst)
		self.inst = inst
		self._tickrate = 0
		self.level = 1
		self.stiletto = nil -- 存储雷楔的ins引用，仅在state为true时有效
		self.maxcd = 7.5 -- 默认冷却时间 7.5s 释放state进入2,5s内释放第二段，否则直接转回状态0，雷楔失效 当然可选引爆直接转回状态0
		self.cd = 0.0 -- 当前冷却时间
		self.state = false -- 技能状态 处理二段战技 不进行保存
	end,
	nil,
	{
		maxcd = function(self, value)
			makeDirty(self, "maxcd", value)
		end,
		level = function(self, value, old)
			makeDirty(self, "level", value)
		end,
		cd = function(self, value)
			self._tickrate = self._tickrate + 1
			if value <= 0 or self._tickrate >= 3 then
				self._tickrate = 0
				makeDirty(self, "cd", value)
			end
			-- SetValue(self, "cd", value)
		end,
		state = function(self, value)
			makeDirty(self, "state", value)
		end,
	}
)

function Skill:OnSave()
	return { cd = self.cd, level = self.level }
end

function Skill:OnLoad(data)
	if data ~= nil then
		self.cd = data.cd or self.maxcd
		self.level = data.level or 1
		if self.cd > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
end

function Skill:OnUpdate(dt)
	self.cd = math.max(self.cd - dt, 0)
	if self.cd == 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function Skill:SetCd()
	self.cd = self.maxcd
	self.inst:StartUpdatingComponent(self)
end
-- 留给如雷
function Skill:DoCdDelta(value)
	modassert(type(value) == "number", "value must be a number")

	self.cd = math.max(0, self.cd - value)
end

function Skill:SetLevel(level)
	modassert(type(level) == "number", "level must be a number")
	self.level = (math.floor(level) - 1) % 15 + 1
end

function Skill:TryDoSkill(pos, doslash)
	local doer = self.inst
	local canDo = doer
		and doer:IsValid()
		and doer.components.health
		and not doer.components.health:IsDead()
		and not doer.sg:HasStateTag("busy")
		and not (doer.components.rider and doer.components.rider:IsRiding())
	if canDo then
		-- debug状态不判断CD
		if not self.state and (TUNING_KEQING.DEBUG or self.cd <= 0) then
			self:CreateStiletto(pos)
			self:SetCd()
			return true
		elseif self.state and doslash ~= nil and doslash then
			-- doslash 是否引爆
			self:RemoveStiletto(2)
			return true
		elseif self.state then
			self:RemoveStiletto(1)
			return true
		end
	end
	return false
end

function Skill:CreateStiletto(pos)
	--  这里设定最大的距离，超过最大距离，那么按照这个角度找到最大的距离的位置
	--
	-- 防止多个雷楔
	self:RemoveStiletto()

	local stiletto = SpawnPrefab("keqing_stiletto")
	stiletto.Transform:SetPosition(pos.x, pos.y, pos.z)
	self.stiletto = stiletto
	self.state = true
	self.onstilettoremove = function()
		self.state = false
	end
	self.inst:ListenForEvent("onremove", self.onstilettoremove, self.stiletto)
	self:SetCd()

	local mult = TUNING_KEQING.SKILL_MULT_DATA[self.level].thunder_wedge_damage / 100
	local range = TUNING_KEQING.SKILL_STULETTO_RANGE
	self.inst.components.keqing_stats:DoAoeAttack(mult, range, pos.x, pos.y, pos.z)
end

function Skill:RemoveStiletto(type)
	if self.stiletto then
		local pos = self.stiletto:GetPosition()
		-- 斩击
		if type == 1 and self.inst.Physics then
			-- 这里判断pos位置是否可以站立，不能的话需要进行修正，
			local pos = FindPlantform(self.inst:GetPosition(), pos)

			self.inst.Physics:Teleport(pos.x, pos.y, pos.z)
			-- 特效过后放在sg里面吧,这里显然不太合适的
			local fx = SpawnPrefab("kq_skill_fx")
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)

			local mult = TUNING_KEQING.SKILL_MULT_DATA[self.level].slash_damage / 100
			local range = TUNING_KEQING.SKILL_SLASH_RANGE
			self.inst.components.keqing_stats:DoAoeAttack(mult, range, pos.x, pos.y, pos.z)
		end
		-- 引爆
		if type == 2 then
			-- 生成引爆特效，造成伤害
			local fx = SpawnPrefab("kq_skill_fx")
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
			-- gpt转出来的倍率默认乘次数了
			local mult = TUNING_KEQING.SKILL_MULT_DATA[self.level].thunderstorm_slash_damage / 100 / 2
			local range = TUNING_KEQING.SKILL_SLASH_RANGE
			self.inst.components.keqing_stats:DoAoeAttack(mult, range, pos.x, pos.y, pos.z)
			self.inst.components.keqing_stats:DoAoeAttack(mult, range, pos.x, pos.y, pos.z)
		end
		-- 没做,进入cd,状态清空,雷楔移除即可
		self.stiletto:Remove()
	end
	-- 不管怎么样 ,雷楔都要移除,状态都要重置
	self.stiletto = nil
end

return Skill
