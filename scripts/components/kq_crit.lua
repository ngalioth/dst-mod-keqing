local kq_crit = Class(function(self, inst)
	self.inst = inst
	self.crit = 0
	self.critdmg = 0
end)

function kq_crit:SetCrit(crit)
	self.crit = crit
end

function kq_crit:SetCritdmg(critdmg)
	self.critdmg = critdmg
end

function kq_crit:GetCrit()
	return self.crit
end

function kq_crit:GetCritdmg()
	return self.critdmg
end

function kq_crit:OnSave()
	return { datcrit = self.crit, datcritdmg = self.critdmg }
end

function kq_crit:OnLoad(data)
	if data.datcrit then
		self.crit = data.datcrit
	end
	if data.datcritdmg then
		self.critdmg = data.datcritdmg
	end
end

return kq_crit
