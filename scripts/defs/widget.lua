-- 添加技能的UI
local skill = require("widgets/skill")
local burst = require("widgets/burst")
AddClassPostConstruct("widgets/controls", function(self)
	if self.owner and self.owner.prefab == "keqing" then
		self.keqing_skill = self:AddChild(skill(self.owner))
		self.keqing_burst = self:AddChild(burst(self.owner))
	end
end)
-- test passed
AddClassPostConstruct("widgets/controls", function(self)
	local oldOnSetPlayerMod = self.OnSetPlayerMod
	local oldSetGhostMode = self.SetGhostMode
	if self.owner and self.owner.prefab == "keqing" then
		self.OnSetPlayerMod = function(inst, self, ...)
			if self.on_burst_delta == nil then
				self.on_burst_delta = function(owner, data)
					self.keqing_burst:SetEnergy(data.burst_energy, data.burst_current_energy)
					self.keqing_burst:SetCd(data.burst_cd, data.burst_current_cd)
				end
				self.inst:ListenForEvent("burst_delta", self.on_burst_delta, self.owner)
			end
			return oldOnSetPlayerMod(inst, self, ...)
		end
		self.SetGhostMode = function(self, isghost, ...)
			if self.owner and self.owner.prefab == "keqing" then
				if self.on_burst_delta then
					self.inst:RemoveEventCallback("burst_delta", self.on_burst_delta, self.owner)
					self.on_burst_delta = nil
				end
				if isghost then
					self.keqing_skill:Hide()
					self.keqing_burst:Hide()
				else
					self.keqing_skill:Show()
					self.keqing_burst:Show()
				end
			end

			return oldSetGhostMode(self, isghost, ...)
		end
	end
end)
