--- 该组件管理语音 台词等的东西以及一些行为相关的开关等，当然包括classified
local Keqing = Class(function(self, inst)
	self.inst = inst
	self.classified = nil
	self.opentask = nil
	self.onrefine = nil
end, nil, nil)
