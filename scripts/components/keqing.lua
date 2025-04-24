local function onSprintDirty(self, enabled)
	self.inst.replica.keqing:EnableSprint(enabled)
end
--- 该组件管理语音 台词等的东西以及一些行为相关的开关等，当然包括classified
-- 顺便统一管理一些rpc和本地设置的东西吧，原本的太傻x了
-- 变量同步在keqing_classified里面
local Keqing = Class(
	function(self, inst)
		self.inst = inst
		self.sprint = false
		self.isSoundEnabled = true
	end,
	nil,
	{
		sprint = onSprintDirty,
	}
)
function Keqing:EnableSprint(enable)
	if enable then
		self.sprint = true
	else
		self.sprint = false
	end
end

return Keqing
