local SourceModifierList = require("util/sourcemodifierlist")
local CRIT_BASE = 0.05
local CRITDMG_BASE = 1.884
local BONUS_BASE = 1
local ENERGY_RECHARGE_BASE = 1.0

local Damage_Bonus_Manager = Class(function(self, inst)
	self.inst = inst
	self.hascrit = false
	self.crit = SourceModifierList(self.inst, CRIT_BASE, SourceModifierList.additive)
	self.critdmg = SourceModifierList(self.inst, CRITDMG_BASE, SourceModifierList.additive)
	self.bonus = SourceModifierList(self.inst, BONUS_BASE, SourceModifierList.additive)
	self.energy_recharge = SourceModifierList(self.inst, ENERGY_RECHARGE_BASE, SourceModifierList.additive)
end)
function Damage_Bonus_Manager:GetDamageBonus()
	if math.random() <= self.crit:Get() then
		self.hascrit = true
		return self.bonus:Get() * self.critdmg:Get()
	end
	self.hascrit = false
	return self.bonus:Get()
end
--- 非得把两个customdmgfn分开，神经
--- 不是保险方案，但是兼容性来说应该是最好的了
function Damage_Bonus_Manager:GetSpDamageBonus()
	if self.hascrit == true then
		return self.bonus:Get() * self.critdmg:Get()
	end
	return self.bonus:Get()
end

return Damage_Bonus_Manager
