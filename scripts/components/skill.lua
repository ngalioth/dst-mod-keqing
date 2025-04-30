---------------------------------------------------
local function NoPlayersOrHoles(pt)
	return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end
--- 首先直接检查目标位置
--- 再目标附件搜索 这个设定半径，半径设定不会太大，防止过于夸张的平移
---
--- 那么再按照当前位置往目标位置搜索最近的可以站立的位置

local function TryLocate(pos, target_pos)
	-- 检查

	-- 搜索

	-- 搜索位移位置
	return target_pos
end

---------------------------------------------------

local function onCurrentCdChange(self, cd)
	-- self.inst.replica.Skill:SetCurrentCd(cd)
end
local function onStateChange(self, state)
	-- self.inst.replica.Skill:SetState(state)
end

local thunder_wedge_damage = 50.0 / 100
local slash_damage = 168 / 100
local thunderstorm_slash_damage = 84 / 100

local thunder_wedge_range = 2

local slash_range = 2
local thunderstorm_slash_range = 10

-- 该组件管理战技的cd、能量、冷却时间、技能等级，管理雷楔，下线应当消失重置状态的
-- 战技释
-- 第一段
-- 二段 位移，战技，移除雷楔
-- 引爆 移除雷楔，造成伤害
-- 没释放进入cd雷楔需要移除，状态需要清空

local Skill = Class(
	function(self, inst)
		self.inst = inst
		self.stiletto = nil -- 存储雷楔的ins引用，仅在state为true时有效
		self.maxcd = 7.5 -- 默认冷却时间 7.5s 释放state进入2,5s内释放第二段，否则直接转回状态0，雷楔失效 当然可选引爆直接转回状态0
		self.cd = 0.0 -- 当前冷却时间
		self.state = false -- 技能状态 处理二段战技 不进行保存
	end,
	nil,
	{
		cd = onCurrentCdChange, -- 技能剩余cd
		state = onStateChange, -- 特殊状态 仅true false
	}
)
function Skill:OnSave()
	return {
		cd = self.cd,
	}
end
function Skill:OnLoad(data)
	if data ~= nil then
		self.cd = data.cd or self.maxcd
		if self.cd > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
end
function Skill:OnUpdate(dt)
	self.cd = self.cd - dt
	if self.cd <= 2.5 then
		self:RemoveStiletto() -- 二段状态失效，进入cd 同时要将雷楔移除
	end
	if self.cd <= 0 then
		self.cd = 0
		self.inst:StopUpdatingComponent(self)
	end
end
-- 下线要保证雷楔被清空
function Skill:OnRemoveEntity()
	self:RemoveStiletto()
end

function Skill:SetCd()
	self.cd = self.maxcd
	self.inst:StartUpdatingComponent(self)
end

function Skill:TryDoSkill()
	local doer = self.inst
	local canDo = doer
		and doer:IsValid()
		and doer.components.health
		and not doer.components.health:IsDead()
		and not doer.sg:HasStateTag("busy")
		and not (doer.components.rider and doer.components.rider:IsRiding())
	if canDo then
		if not self.state then
			self:CreateStiletto()
		else
			-- 缺个判断是否引爆的参数，得加到rpc里面 先默认连斩吧
			self:RemoveStiletto(1)
		end
	end
	if not TUNING_KEQING.DEBUG then
		self:SetCd()
	end
end

function Skill:CreateStiletto(target_pos)
	--- 仅独行长路下，后面得额外处理，客户端往服务器发坐标
	local target_pos = target_pos or TheInput:GetWorldPosition() -- 鼠标坐标
	local pos = self.inst:GetPosition() --- 玩家当前坐标

	--  这里设定最大的距离，超过最大距离，那么按照这个角度找到最大的距离的位置
	--
	--
	-- 防止多个雷楔
	self:RemoveStiletto()
	local stiletto = SpawnPrefab("keqing_stiletto")
	stiletto.Transform:SetPosition(target_pos.x, target_pos.y, target_pos.z)

	self.stiletto = stiletto
	self.state = true
	self.inst.components.keqing_aoe_dmg:DoAoeAttack(
		thunder_wedge_damage,
		thunder_wedge_range,
		target_pos.x,
		target_pos.y,
		target_pos.z
	)
end

function Skill:RemoveStiletto(type)
	if self.stiletto then
		local pos = self.stiletto:GetPosition()
		-- 斩击
		if type == 1 then
			if self.inst.Physics then
				-- 这里判断pos位置是否可以站立，不能的话需要进行修正，
				local pos = TryLocate(self.inst:GetPosition(), pos)

				self.inst.Physics:Teleport(pos.x, pos.y, pos.z)
				-- 特效过后放在sg里面吧,这里显然不太合适的
				local fx = SpawnPrefab("kq_skill_fx")
				fx.Transform:SetPosition(pos.x, pos.y, pos.z)

				self.inst.components.keqing_aoe_dmg:DoAoeAttack(slash_damage, slash_range, pos.x, pos.y, pos.z)
			end
		end
		-- 引爆
		if type == 2 then
			-- 生成引爆特效，造成伤害
			local fx = SpawnPrefab("kq_skill_fx")
			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
			self.inst.components.keqing_aoe_dmg:DoAoeAttack(
				thunderstorm_slash_damage,
				thunderstorm_slash_range,
				pos.x,
				pos.y,
				pos.z
			)
		end
		-- 没做,进入cd,状态清空,雷楔移除即可
		self.stiletto:Remove()
	end
	-- 不管怎么样 ,雷楔都要移除,状态都要重置
	self.stiletto = nil
	self.state = false
end

return Skill
