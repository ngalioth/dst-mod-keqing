local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local skill = Class(Widget, function(self, owner)
	Widget._ctor(self, "skill")
	self.owner = owner

	self:SetHAnchor(2)
	self:SetVAnchor(2)
	self:SetPosition(-1350, 140, 0)
	self:SetScale(0.75, 0.75, 0.75)

	self.image_init = self:AddChild(Image("images/skills/skill0.xml", "skill0.tex"))
	self.image_delta = self:AddChild(Image("images/skills/skill1.xml", "skill1.tex"))

	self.cd = self:AddChild(Text(BODYTEXTFONT, 60))
	self.cd:SetHAlign(ANCHOR_MIDDLE)
	self.cd:MoveToFront()

	self:StartUpdating()
	self.click = false
end)

function skill:OnUpdate(dt)
	local timeleft = self.owner.skillcdleft:value() or 0
	self.cd:SetString(string.format("%.1f", timeleft))
	if self.owner:HasTag("playerghost") then
		self.cd:Hide()
		self.image_init:Hide()
		self.image_delta:Hide()
	else
		if self.owner.ChangeSkillIcon1:value() then
			self.cd:Hide()
			self.image_init:Hide()
			self.image_delta:Show()
		else
			if timeleft > 0 then
				self.cd:Show()
				self.image_init:Show()
				self.image_delta:Hide()
			else
				self.cd:Hide()
				self.image_init:Show()
				self.image_delta:Hide()
			end
		end
	end
end

return skill