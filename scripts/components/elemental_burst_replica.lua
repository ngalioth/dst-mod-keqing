local Elemental_Burst = Class(function(self, inst)
	self.inst = inst
	self.level = 1

	if TheWorld.ismastersim then
		self.classified = inst.keqing_classified
	elseif self.classified == nil and inst.keqing_classified ~= nil then
		self:AttachClassified(inst.keqing_classified)
		-- 测试使用
		self.hasAttached = false
	end
end)

--- 这俩函数其实是给classified调用的，由于设置了classifiedTarget，设置之前classified对player是不可见的，只能让他自己来调用attach绑定
function Elemental_Burst:AttachClassified(classified)
	self.classified = classified
	self.ondetachclassified = function()
		self:DetachClassified()
	end
	self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Elemental_Burst:DetachClassified()
	self.classified = nil
	self.ondetachclassified = nil
end
return Elemental_Burst
