local assets = {
	Asset("ANIM", "anim/kq_lightstone.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_lightstone.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_lightstone.xml"),
}

local function onequip(inst, owner) --装备的函数
	inst.light = SpawnPrefab("light")
	inst.light.entity:SetParent(owner.entity)
end

local function onunequip(inst, owner) --解除装备
	if inst.light ~= nil then
		inst.light:Remove()
	end
end

local function fn()
	local assetname = "kq_lightstone"
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname) -- 地上动画
	inst.AnimState:SetBuild(assetname) -- 材质包，就是anim里的zip包
	inst.AnimState:PlayAnimation("idle") -- 默认播放哪个动画

	MakeInventoryFloatable(inst)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.light = nil

	inst:AddComponent("inspectable") -- 可检查组件
	inst:AddComponent("inventoryitem") -- 物品组件
	inst.components.inventoryitem.imagename = "kq_lightstone"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_lightstone.xml" -- 在背包里的贴图

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY -- 护符栏位到底对不对呢？
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	return inst
end

local function lightfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Light:SetRadius(4)
	inst.Light:SetFalloff(0.75)
	inst.Light:SetIntensity(0.65)
	inst.Light:SetColour(255 / 255, 255 / 255, 255 / 255)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

return Prefab("kq_lightstone", fn, assets), Prefab("light", lightfn)
