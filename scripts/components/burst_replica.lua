-- replica 仅作为客户端获取数据通道 classified里面提供部分接口封装
local Burst = Class(function(self, inst)
	self.inst = inst
	if TheWorld.ismastersim then
		-- 一样的问题，服务端这里keqing_classified是空气,导致没法attach
		self.classified = inst.keqing_classified
	elseif self.classified == nil and inst.keqing_classified ~= nil then
		self:AttachClassified(inst.keqing_classified)
	end
end)

--- 这俩函数其实是给classified调用的，由于设置了classifiedTarget，设置之前classified对player是不可见的，只能让他自己来调用attach绑定
function Burst:AttachClassified(classified)
	self.classified = classified
	self.ondetachclassified = function()
		self:DetachClassified()
	end
	self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Burst:DetachClassified()
	self.classified = nil
	self.ondetachclassified = nil
end

function Burst:GetValue(name)
	if self.inst.components.Burst ~= nil then
		return self.inst.components.Burst[name]
	end
	if self.classified ~= nil then
		return self.classified["burst_" .. name]:value()
	end
	return 1
end

return Burst
