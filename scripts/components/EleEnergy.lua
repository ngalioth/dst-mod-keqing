local function onmax(self, max)
	self.inst.maxenergy:set(max)
end

local function oncurrent(self, current)
	self.inst.currentenergy:set(current)
end

local EleEnergy = Class(
	function(self, inst)
		self.inst = inst
		self.max = 40
		self.current = 0
		inst:ListenForEvent("onhitother", function(inst, data)
			if data.target and not inst:HasTag("noenergy") then
				self:DoDelta(0.4)
			end
		end)
		inst:ListenForEvent("killed", function(inst, data)
			if data.target and not inst:HasTag("noenergy") then
				self:DoDelta(3)
			end
		end)
		inst:ListenForEvent("ms_respawnedfromghost", function()
			self.current = 0
		end)
	end,
	nil,
	{
		max = onmax,
		current = oncurrent,
	}
)

function EleEnergy:OnSave()
	return { energy = self.current }
end

function EleEnergy:OnLoad(data)
	if data.energy then
		self.current = data.energy
		self:DoDelta(0)
	end
end

function EleEnergy:LongUpdate(dt)
	self:DoDec(dt, true)
end

function EleEnergy:GetDebugString()
	return string.format("%2.2f / %2.2f", self.current, self.max)
end

function EleEnergy:SetMax(amount)
	self.max = amount
	self.current = amount
end

function EleEnergy:DoDelta(delta)
	self.current = self.current + delta
	if self.current < 0 then
		self.current = 0
	elseif self.current > self.max then
		self.current = self.max
	end
end

function EleEnergy:GetPercent()
	return self.current / self.max
end

function EleEnergy:GetCurrent()
	return self.current
end

function EleEnergy:SetPercent(p)
	self.current = p * self.max
end

return EleEnergy
