
local Refinement = Class(function(self, inst)
	self.inst = inst
	self.record = {}
	self.onrefine = nil
    self.inst:AddTag("refinement")
end,nil,nil)

function Refinement:OnRecordDirty()
    self.inst.replica.refinement._record:set(json.encode(self.record))
end
function Refinement:OnSave()
	local rec = json.encode(self.record)
	dumptable(rec)
	return {
		record = rec,
	}
end

function Refinement:OnLoad(data)
	if data then
		if data.record then
			self.record = json.decode(data.record)
		end
	end
    self:OnRecordDirty()
	-- 由于外部无法保存部分数据，这里加载时重新赋值
	if self.onrefine ~= nil then
		self.onrefine(self.inst)
	end

end

function Refinement:AddRefineable(prefab, startValue, maxValue)
	if self.record[prefab] == nil then
		self.record[prefab] = {}
	end
	self.record[prefab] = {
		current = startValue,
		max = maxValue or nil, -- nil表示无上限
	}
    self:OnRecordDirty()
end
function Refinement:GetRefineLevel(prefab)
	return (self.record[prefab] and self.record[prefab].current) or 0
end

function Refinement:SetOnRefine(fn)
	self.onrefine = fn
end
function Refinement:CanAcceptItem(prefab_name)
	local item = self.record[prefab_name]
	return item ~= nil and (item.max == nil or item.current < item.max) or false
end
function Refinement:DoRefine(obj, doer)
	local prefab = obj.prefab
	-- if not self:CanAcceptItem(prefab) then
	-- 	return false
	-- end
	--- 精练 向后合并record表
	if self.inst.prefab == prefab then
		for k, v in pairs(obj.components.refinement.record) do
			local item = self.record[k]
			if not item then
				self.record[k] = { current = v.current, max = v.max }
			else
				if item.max ~= nil then
					item.current = math.min(item.current + v.current, item.max)
				else
					item.current = item.current + v.current
				end
			end
		end
	else -- 升级或者解锁逻辑
		local record = self.record[prefab]
		-- 这里不能交换，nil无上限或者有上限且小于最大时才执行
		if record.max == nil or record.current < record.max then
			record.current = record.current + 1
		end
	end
	if self.onrefine ~= nil then
		self.onrefine(self.inst, doer, obj)
	end
    self:OnRecordDirty()
	return true
end
return Refinement
