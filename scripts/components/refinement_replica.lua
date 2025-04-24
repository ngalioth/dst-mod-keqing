
--- 仅仅是为了组件的客户端动作testfn和stroverride
local Refinement = Class(function(self, inst)
	self.inst = inst
	self.record = {}
    self._record = net_string(inst.GUID, "refinement._record", "record_dirty")
    if not TheWorld.ismastersim then
        inst:ListenForEvent("record_dirty", function(inst) self:SetRecord(self._record:value()) end)
    end
end)

function Refinement:SetRecord(record)
    self.record = json.decode(record)
end
function Refinement:CanAcceptItem(prefab_name)
	local item = self.record[prefab_name]
	return item ~= nil and (item.max == nil or item.current < item.max) or false
end
return Refinement
