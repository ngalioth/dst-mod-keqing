local goldenshrimp_assets = {
	Asset("ANIM", "anim/kq_goldenshrimp.zip"),
	Asset("IMAGE", "images/food/kq_goldenshrimp.tex"),
	Asset("ATLAS", "images/food/kq_goldenshrimp.xml"),
}

local pocketcake_assets = {
	Asset("ANIM", "anim/kq_pocketcake.zip"),
	Asset("IMAGE", "images/food/kq_pocketcake.tex"),
	Asset("ATLAS", "images/food/kq_pocketcake.xml"),
}

local grilledfish_assets = {
	Asset("ANIM", "anim/kq_grilledfish.zip"),
	Asset("IMAGE", "images/food/kq_grilledfish.tex"),
	Asset("ATLAS", "images/food/kq_grilledfish.xml"),
}

local friedegg_assets = {
	Asset("ANIM", "anim/kq_friedegg.zip"),
	Asset("IMAGE", "images/food/kq_friedegg.tex"),
	Asset("ATLAS", "images/food/kq_friedegg.xml"),
}

local function onhaunt(inst)
	inst.Remove()
end

local function commonfn(name, hunger, sanity, health)
	local assetname = name

	local inst = CreateEntity() -- 创建实体
	inst.entity:AddTransform() -- 添加xyz形变对象
	inst.entity:AddAnimState() -- 添加动画状态
	inst.entity:AddNetwork() -- 添加这一行才能让所有客户端都能看到这个实体

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname) -- 地上动画
	inst.AnimState:SetBuild(assetname) -- 材质包，就是anim里的zip包
	inst.AnimState:PlayAnimation("idle") -- 默认播放哪个动画

	MakeInventoryFloatable(inst)
	--------------------------------------------------------------------------
	if not TheWorld.ismastersim then
		return inst
	end
	--------------------------------------------------------------------------
	inst:AddTag("preparedfood")
	inst:AddComponent("inspectable") -- 可检查组件
	inst:AddComponent("inventoryitem") -- 物品组件
	inst.components.inventoryitem.imagename = name
	inst.components.inventoryitem.atlasname = "images/food/" .. name .. ".xml" -- 在背包里的贴图

	inst:AddComponent("edible") -- 可食物组件
	--inst.components.edible.foodtype = FOODTYPE.MEAT --肉类食物

	inst:AddComponent("perishable") -- 可腐烂的组件
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food" -- 腐烂后变成腐烂食物

	inst.components.edible.hungervalue = hunger
	inst.components.edible.healthvalue = health
	inst.components.edible.sanityvalue = sanity

	inst:AddComponent("stackable") -- 可堆叠
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("hauntable")

	return inst
end

local function kq_goldenshrimp()
	local inst = commonfn("kq_goldenshrimp", 75, 20, 40)
	inst:AddComponent("hauntable")
	MakeHauntableLaunch(inst)
	return inst
end

local function kq_pocketcake()
	local inst = commonfn("kq_pocketcake", 120, 5, 20)
	inst:AddComponent("hauntable")
	MakeHauntableLaunch(inst)
	return inst
end

local function kq_grilledfish()
	local inst = commonfn("kq_grilledfish", 50, 5, 20)
	inst:AddComponent("hauntable")
	MakeHauntableLaunch(inst)
	return inst
end

local function kq_friedegg()
	local inst = commonfn("kq_friedegg", 40, 20, 20)
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
	inst.components.hauntable:SetOnHauntFn(onhaunt)
	return inst
end

return Prefab("kq_goldenshrimp", kq_goldenshrimp, goldenshrimp_assets),
	Prefab("kq_pocketcake", kq_pocketcake, pocketcake_assets),
	Prefab("kq_grilledfish", kq_grilledfish, grilledfish_assets),
	Prefab("kq_friedegg", kq_friedegg, friedegg_assets)
