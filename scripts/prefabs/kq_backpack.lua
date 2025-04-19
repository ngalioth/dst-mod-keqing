local assets = {
	Asset("ANIM", "anim/kq_swap_backpack.zip"),
	--Asset("ANIM", "anim/kq_backpack_2x6.zip"),
	Asset("ANIM", "anim/kq_backpack_2x10.zip"),
	Asset("ATLAS", "images/inventoryimages/kq_backpack.xml"),
	Asset("IMAGE", "images/inventoryimages/kq_backpack.tex"),
}

local containers = require("containers")
local params = containers.params
params.kq_backpack = {
	widget = {
		slotpos = {},
		animbank = "ui_krampusbag_2x8",
		animbuild = "kq_backpack_2x10",
		pos = Vector3(-5, -90, 0),
	},
	issidewidget = true,
	type = "pack",
	openlimit = 1,
}

for y = 0, 9 do
	table.insert(params.kq_backpack.widget.slotpos, Vector3(-160, -75 * y + 340, 0))
	table.insert(params.kq_backpack.widget.slotpos, Vector3(-160 + 75, -75 * y + 340, 0))
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "kq_swap_backpack", "swap_body") --三个参数分别是替换的贴图是swap_body  使用的动画是kq_swap_backpack  第三个这个注意 这个swap_body是你的动画里装图片的文件夹的名字
	if inst.components.container ~= nil then
		inst.components.container:Open(owner)
	end
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")
	if inst.components.container ~= nil then
		inst.components.container:Close(owner)
	end
end

local function onequiptomodel(inst, owner)
	inst.components.container:Close(owner)
end

local function fn()
	local inst = CreateEntity()
	local assetname = "kq_swap_backpack"

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("fridge") -- 保鲜
	inst:AddTag("nosteal") -- 防偷取
	inst:AddTag("kq_backpack") -- 后续可能会用到？
	inst:AddTag("hide_percentage") -- 隐藏百分比

	inst:AddComponent("inspectable") -- 可以检查
	inst:AddComponent("inventoryitem") -- 物品
	inst.components.inventoryitem.imagename = "kq_backpack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_backpack.xml"
	inst.components.inventoryitem.cangoincontainer = false

	inst:AddComponent("waterproofer") -- 防水
	inst.components.waterproofer:SetEffectiveness(0.60)

	inst:AddComponent("armor") -- 护甲
	inst.components.armor:InitIndestructible(0.80)

	inst:AddComponent("planardefense") -- 位面防御
	inst.components.planardefense:SetBaseDefense(10)

	inst:AddComponent("equippable") -- 可装备
	inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY -- 装备栏（适应五格？）
	--inst.components.equippable.restrictedtag = "keqing"
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable:SetOnEquipToModel(onequiptomodel)
	inst.components.equippable.walkspeedmult = 1.25

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("kq_backpack")

	MakeHauntableLaunch(inst)
	return inst
end

return Prefab("kq_backpack", fn, assets)
