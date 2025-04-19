local key = Class(function(self, inst)
	self.inst = inst
end)

function key:Press(Key, Action)
	TheInput:AddKeyDownHandler(Key, function()
		if self.inst == ThePlayer and TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "HUD" then
			if TheFrontEnd:GetActiveScreen() then
				local x, y, z = (TheInput:GetWorldPosition()):Get()
				SendModRPCToServer(MOD_RPC[self.inst.prefab][Action], x, y, z)
			end
		end
	end)
end

return key
