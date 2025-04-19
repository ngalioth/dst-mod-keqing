local assets = {
	Asset("ANIM", "anim/kq_foodbag.zip"),
	Asset("ATLAS", "images/inventoryimages/kq_foodbag.xml"),
	Asset("IMAGE", "images/inventoryimages/kq_foodbag.tex"),
	Asset("ANIM", "anim/kq_foodbag_3x3.zip"),
}

local containers = require("containers")
local params = containers.params
params.kq_foodbag = {
	widget = {
		slotpos = {},
		animbank = "kq_foodbag_3x3",
		animbuild = "kq_foodbag_3x3",
		pos = Vector3(0, 200, 0),
		side_align_tip = 160,
	},
	type = "chest",
}

for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(params.kq_foodbag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
	end
end

function params.kq_foodbag.itemtestfn(container, item, slot)
	if item:HasTag("icebox_valid") and not item.prefab == "heatrock" and not item.prefab == "dumbbell_heat" then
		return true
	end
	--Perishable
	if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
		return false
	end
	if item:HasTag("smallcreature") then
		return true
	end
	--Edible
	for k, v in pairs(FOODTYPE) do
		if item:HasTag("edible_" .. v) then
			return true
		end
	end
	return false
end

local function refresh(inst, item)
	return (item ~= nil) and -1 or nil
end

local function fn()
	local assetname = "kq_foodbag"
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("nosteal")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "kq_foodbag"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_foodbag.xml"

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("kq_foodbag")
	inst.components.container.skipclosesnd = true
	inst.components.container.skipopensnd = true

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(refresh) --保鲜
	return inst
end

return Prefab("kq_foodbag", fn, assets)
