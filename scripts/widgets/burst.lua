local Widget = require("widgets/widget")
local Text = require("widgets/text")
local UIAnim = require("widgets/uianim")

local burst = Class(Widget, function(self, owner)
	Widget._ctor(self, "burst")
	self.owner = owner

	self:SetHAnchor(2)
	self:SetVAnchor(2)
	self:SetPosition(-1450, 150, 0)
	self:SetScale(1, 1, 1)

	-- self.currentenergy = owner.currentenergy:value()
	-- self.maxenergy = owner.maxenergy:value()
	-- self.percent = self.currentenergy / self.maxenergy

	self.currentenergy = 1
	self.maxenergy = 1
	self.percent = 1
	self.time = 0

	self.anim = self:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("energy")
	self.anim:GetAnimState():SetBuild("energy")
	if self.percent < 0.25 and self.percent >= 0 then
		self.anim:GetAnimState():PlayAnimation("idle")
	elseif self.percent < 0.5 and self.percent >= 0.25 then
		self.anim:GetAnimState():PlayAnimation("quarter")
	elseif self.percent < 0.75 and self.percent >= 0.5 then
		self.anim:GetAnimState():PlayAnimation("half")
	elseif self.percent < 1 and self.percent >= 0.75 then
		self.anim:GetAnimState():PlayAnimation("halffull")
	else
		self.anim:GetAnimState():PlayAnimation("full")
	end

	self.cd = self:AddChild(Text(BODYTEXTFONT, 60))
	self.cd:SetHAlign(ANCHOR_MIDDLE)
	self.cd:MoveToFront()

	self:StartUpdating()

	owner:ListenForEvent("burst_energy_delta", function()
		-- self.currentenergy = owner.currentenergy:value()
		self.currentenergy = owner.replica.burst:GetValue("energy")
		self.percent = self.currentenergy / self.maxenergy
	end)

	owner:ListenForEvent("burst_maxenergy_delta", function()
		-- self.maxenergy = owner.maxenergy:value()
		self.maxenergy = owner.replica.burst:GetValue("maxenergy")
		self.percent = self.currentenergy / self.maxenergy
	end)
	owner:ListenForEvent("burst_cd_delta", function()
		self.time = owner.replica.burst:GetValue("cd")
	end)

	self.click = false
end)

function burst:OnUpdate(dt)
	self.cd:SetString(string.format("%.1f", self.time))
	if self.percent < 0.25 and self.percent >= 0 then
		self.anim:GetAnimState():PlayAnimation("idle")
	elseif self.percent < 0.5 and self.percent >= 0.25 then
		self.anim:GetAnimState():PlayAnimation("quarter")
	elseif self.percent < 0.75 and self.percent >= 0.5 then
		self.anim:GetAnimState():PlayAnimation("half")
	elseif self.percent < 1 and self.percent >= 0.75 then
		self.anim:GetAnimState():PlayAnimation("halffull")
	else
		self.anim:GetAnimState():PlayAnimation("full")
	end
	if self.owner:HasTag("playerghost") then
		self.cd:Hide()
		self.anim:Hide()
	else
		self.anim:Show()
		if self.time > 0 then
			self.cd:Show()
		else
			self.cd:Hide()
		end
	end
end

return burst
