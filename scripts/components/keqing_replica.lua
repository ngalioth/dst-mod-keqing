--------------------------------------------------------------------------
local Keqing = Class(function(self, inst)
	self.inst = inst

	--[[ 主机初始化 ]]
	if TheWorld.ismastersim then
		if inst:HasTag("player") then
			self.classified = SpawnPrefab("keqing_classified")
			-- 因为这个classified是必然链接的，所以也不用考虑太多。或许ghost状态要考虑一下？但也可以其他方式禁用
			self.classified.entity:SetParent(inst.entity)
		end
	elseif self.classified == nil and inst.keqing_classified ~= nil then
		self.classified = inst.keqing_classified
		inst.keqing_classified.OnRemoveEntity = nil
		inst.keqing_classified = nil
		self:AttachClassified(self.classified)
	end
end)
-- 客户端链接classified
function Keqing:AttachClassified(classified)
	self.classified = classified

	self.ondetachclassified = function()
		self:DetachClassified()
	end
	self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)

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
			-- if self.opentask ~= nil then
			-- 	self.opentask:Cancel()
			-- 	self.opentask = nil
			-- end
			-- self.inst.components.inventory:Close(true)
			self.classified:Remove()
			self.classified = nil
		else
			self.classified._parent = nil
			self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
			self:DetachClassified()
		end
	end
end
