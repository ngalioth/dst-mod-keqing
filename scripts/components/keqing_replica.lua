--------------------------------------------------------------------------
-- 饥荒ent的恢复逻辑
--- 先创建实体，添加全部组件
--- 添加data里面可能缺失的组件(flag设置,有个例子是拟态蠕虫)，分别执行添加的组件各个OnLoad,最后实体的OnLoad
-- 具体的可以参考SpawanSaveRecord
-- 倒也不用担心会找不到classified的问题了
-- 由于该组件负责classified初始化，依赖该classified的组件需要在该组件之后初始化
-- 所以加载必须在该组件之后
local Keqing = Class(function(self, inst)
	self.inst = inst
	-- 该replica同时负责classified的创建，主机上可以通过ins.keqing_classified访问,客机只能访问
	if TheWorld.ismastersim then
		if inst:HasTag("player") then
			inst.keqing_classified = SpawnPrefab("keqing_classified")
			inst.keqing_classified.delayclientdespawn = true
			self.classified = inst.keqing_classified
			-- 因为这个classified是必然链接的，所以也不用考虑太多。或许ghost状态要考虑一下？但也可以其他方式禁用
			self.classified.entity:SetParent(inst.entity)
			self.classified._parent = inst
			-- 该实体只需要和当前player交互
			--- 这一步必须在组件实例化结束后执行，否则无效 onsetowner
			-- self.classified.Network:SetClassifiedTarget(inst)
		end
	elseif self.classified == nil and inst.keqing_classified ~= nil then
		self.classified = inst.keqing_classified
		--- 参考inventory_replica,但是下面两句没看懂
		-- 疑似是防止其他组件乱用？
		-- inst.keqing_classified.OnRemoveEntity = nil
		-- inst.keqing_classified = nil
		self:AttachClassified(self.classified)
	end
end)
-- 客户端链接classified
function Keqing:AttachClassified(classified)
	self.classified = classified

	self.ondetachclassified = function()
		self:DetachClassified()
	end
	self.inst:ListenForEvent("onremove", self.ondetachclassified, self.classified)
	-- 实体监听classified，在classified移除之前要先detach

	-- self.inst:ListenForEvent("visibledirty", OnVisibleDirty, classified)
	-- self.inst:ListenForEvent("heavyliftingdirty", OnHeavyLiftingDirty, classified)
	-- classified:DoStaticTaskInTime(0, OnVisibleDirty)
end
function Keqing:DetachClassified()
	self.classified = nil
	self.ondetachclassified = nil
end
--- 客户端组件 双端都会存在
--- 服务端移除时需要移除classified实体
--- 客户端移除时需要移除classified的链接，包括event和parent设置，没有parent的classified会自动移除
function Keqing:OnRemoveEntity()
	if self.classified ~= nil then
		if TheWorld.ismastersim then
			self.classified:Remove()
			self.classified = nil
		else
			self.classified._parent = nil
			self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
			self:DetachClassified()
		end
	end
end

function Keqing:EnableSprint(enabled)
	if self.classified ~= nil then
		self.classified.sprint:set(enabled)
	end
end
return Keqing
