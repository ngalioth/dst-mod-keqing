--移除预制物(预制物,数量)
local function removeItem(item,num)
	if item.components.stackable then
		item.components.stackable:Get(num):Remove()
	else
		item:Remove()
	end
end

local REFINEMENT = AddAction("REFINEMENT", "通用升级", function(act)
    if act.invobject and act.doer and act.target then
        act.target.components.refinement:DoRefine(act.invobject, act.doer)
        removeItem(act.invobject, 1)
        return true
    end
end)
REFINEMENT.priority = 10
REFINEMENT.stroverridefn = function(act)
	local invobj = act.invobject
	local target = act.target
	if invobj ~= nil and target ~= nil then
		if target.replica.refinement and invobj.prefab == target.prefab then
			return "精练"
		end
		if target.prefab == "keqing_pjc" or "kq_hairpins" then
			return "升级"
		end
	end
end
AddStategraphActionHandler("wilson", ActionHandler(REFINEMENT, "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(REFINEMENT, "give"))
AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
	if right then
		local canAccept
		if target and target.components.refinement and target.components.refinement:CanAcceptItem(inst.prefab) then
			canAccept = true
		end
		if target and target.replica.refinement and target.replica.refinement:CanAcceptItem(inst.prefab) then
			canAccept = true
		end
		if canAccept then
			table.insert(actions, ACTIONS.REFINEMENT)
		end
	end
end)

--- 兼容行为学，参考勋章
local queueractlist = {
    [REFINEMENT.id] = true
}
local actionqueuer_status,actionqueuer_data = pcall(require,"components/actionqueuer")
if actionqueuer_status then
	if AddActionQueuerAction and next(queueractlist) then
    	for k,v in pairs(queueractlist) do
    		AddActionQueuerAction(v,k,true)
    	end
    end
end