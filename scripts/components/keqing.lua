function onIsDashEnabled(self, isDashEnabled)
	self.inst.replica.keqing:EnableDash()
end
--- 该组件管理语音 台词等的东西以及一些行为相关的开关等，当然包括classified
-- 顺便统一管理一些rpc和本地设置的东西吧，原本的太傻x了
-- 变量同步在keqing_classified里面
local Keqing = Class(
	function(self, inst)
		self.inst = inst
		self.isDashEnabled = true
		self.isSoundEnabled = true
	end,
	nil,
	{
		isDashEnabled = onIsDashEnabled,
	}
)

return Keqing
