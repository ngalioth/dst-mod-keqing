local Refinement = Class(function(self, inst)
	self.inst = inst
	self.record = {}
	self.onrefine = nil
end)
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
			dumptable(self.record)
		end
	end
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
end
function Refinement:GetRefineLevel(prefab)
	if self.record[prefab] == nil then
		return 0
	end
	return self.record[prefab].current
end

function Refinement:SetOnRefine(fn)
	self.onrefine = fn
end
function Refinement:CanAcceptItem(prefab_name)
	if self.record[prefab_name] == nil then
		return false
	end
	if self.record[prefab_name].max == nil then
		return true
	end
	if self.record[prefab_name].current >= self.record[prefab_name].max then
		return false
	end
	return true
end
function Refinement:DoRefine(obj, doer)
	if self:CanAcceptItem(obj.prefab) then
		--- 精练 向后合并record表
		if self.inst.prefab == obj.prefab then
			for k, v in pairs(obj.components.refinement.record) do
				local item = self.record[k]
				if item == nil then
					self.record[k] = {
						current = v.current,
						max = v.max,
					}
				else
					item.current = item.max ~= nil and math.min(item.current + v.current, item.max)
						or (item.current + v.current)
				end
			end
			if self.onrefine ~= nil then
				self.onrefine(self.inst, doer, obj)
			end
			return true
		else -- 升级或者解锁逻辑
			local prefab = obj.prefab
			local record = self.record[prefab]
			-- 这里不能交换，nil无上限或者有上限且小于最大时才执行
			if record.max == nil or record.current < record.max then
				record.current = record.current + 1
			end
			if self.onrefine ~= nil then
				self.onrefine(self.inst, doer, obj)
			end
			return true
		end
	end
	return false
end
return Refinement
