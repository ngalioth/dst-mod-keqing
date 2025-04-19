local Elemental_Skill = Class(function(self, inst)
	self.inst = inst
	self._current_cd = net_float(inst.GUID, "elemental_skill._current_cd", "onCurrentCd")
	self._state = net_bool(inst.GUID, "elemental_skill._state", "onState")
end)

function Elemental_Skill:SetCurrentCd(cd)
	if self._current_cd ~= nil then
		cd = cd or 0
		self._current_cd:set(cd)
	end
	if Elemental_Skill._cd ~= nil then
		cd = cd or 0
		Elemental_Skill._cd:set(cd)
	end
end
function Elemental_Skill:GetCurrentCd()
	if self.inst.components.elemental_skill ~= nil then
		return self.inst.components.elemental_skill.current_cd
	elseif self._current_cd ~= nil then
		return self._current_cd:value()
	else
		return 0
	end
end
function Elemental_Skill:SetState(state)
	if self._state ~= nil then
		state = state or false
		self._state:set(state)
	end
end
function Elemental_Skill:GetState()
	if self.inst.components.elemental_skill ~= nil then
		return self.inst.components.elemental_skill.state
	elseif self._state ~= nil then
		return self._state:value()
	else
		return 0
	end
end

return Elemental_Skill
