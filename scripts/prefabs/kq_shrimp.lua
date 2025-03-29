local assets =
{
    Asset("ANIM", "anim/kq_shrimp.zip"), -- 虾
    Asset("IMAGE", "images/food/kq_shrimp.tex"),
    Asset("ATLAS", "images/food/kq_shrimp.xml"),

    Asset("ANIM", "anim/kq_cookedshrimp.zip"), -- 熟虾
    Asset("IMAGE", "images/food/kq_cookedshrimp.tex"),
    Asset("ATLAS", "images/food/kq_cookedshrimp.xml"),

    Asset("ANIM", "anim/kq_deadshrimp.zip"), -- 虾仁
    Asset("IMAGE", "images/food/kq_deadshrimp.tex"),
    Asset("ATLAS", "images/food/kq_deadshrimp.xml"),

    Asset("ANIM", "anim/kq_cookeddeadshrimp.zip"), -- 熟虾仁
    Asset("IMAGE", "images/food/kq_cookeddeadshrimp.tex"),
    Asset("ATLAS", "images/food/kq_cookeddeadshrimp.xml"),

    Asset("ANIM", "anim/kq_shrimphead.zip"), -- 虾头
    Asset("IMAGE", "images/food/kq_shrimphead.tex"),
    Asset("ATLAS", "images/food/kq_shrimphead.xml"),

    Asset("ANIM", "anim/kq_steamedshrimphead.zip"), -- 蒸虾头
    Asset("IMAGE", "images/food/kq_steamedshrimphead.tex"),
    Asset("ATLAS", "images/food/kq_steamedshrimphead.xml"),
}

local shrimp_prefabs =
{
    "kq_cookedshrimp",
    "spoiled_food",
}

local deadshrimp_prefabs =
{
    "kq_cookeddeadshrimp",
    "spoiled_food",
}

local shrimphead_prefabs =
{
    "kq_steamedshrimphead"
}

local shrimploot = {"kq_deadshrimp", "kq_shrimphead"} -- 谋杀掉落物

local function common(name, cookable, ediable, healthenable, tradeable, rotable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle")
    inst.scrapbook_anim = name

    inst:AddTag("meat")
    inst:AddTag("catfood")

    MakeInventoryFloatable(inst) -- 可以浮在水面？

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then -- 网络
        return inst
    end

    inst:AddComponent("inspectable") -- 可以检查
    inst:AddComponent("inventoryitem") -- 物品
    inst.components.inventoryitem.imagename = name
    inst.components.inventoryitem.atlasname = "images/food/"..name..".xml" --物品贴图

    inst:AddComponent("stackable") -- 可以堆叠
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    if cookable then -- 可以烹饪？
        inst:AddComponent("cookable")
    end

    if ediable then -- 是否可以食用
        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.MEAT
    end

    if healthenable then -- 是否是活物
        inst:AddComponent("murderable")
        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(shrimploot)
    end

    if tradeable then -- 是否可以交易
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.RAREMEAT -- 价值5金
    end

    if rotable then -- 是否可以腐烂
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"
    end

    MakeHauntableLaunchAndPerish(inst) -- 可作祟

    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function shrimp()
    local inst = common("kq_shrimp", true, true, true, true, true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.build = "kq_shrimp"
    inst.components.cookable.product = "kq_cookedshrimp"
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 0
    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function cookedshrimp()
    local inst = common("kq_cookedshrimp", false, true, false, true, true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.edible.healthvalue = 3
    inst.components.edible.hungervalue = 9.375
    inst.components.edible.sanityvalue = 0
    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function deadshrimp()
	local inst = common("kq_deadshrimp", true, true, false, true, true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.cookable.product = "kq_cookeddeadshrimp"
    inst.components.edible.healthvalue = 1
    inst.components.edible.hungervalue = 12.5
    inst.components.edible.sanityvalue = 0
    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function deadshrimp_cooked()
	local inst = common("kq_cookeddeadshrimp", false, true, false, true, true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.edible.healthvalue = 3
    inst.components.edible.hungervalue = 12.5
    inst.components.edible.sanityvalue = 0
    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function shrimphead()
    local inst = common("kq_shrimphead", true, false, false, false, false)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.cookable.product = "kq_steamedshrimphead"
    return inst
end

--common(name, cookable, ediable, healthenable, tradeable, rotable)
local function steamedshrimphead()
	local inst = common("kq_steamedshrimphead", false, true, false, false, false)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.edible.healthvalue = 6
    inst.components.edible.hungervalue = 6
    inst.components.edible.sanityvalue = 6
    return inst
end

return  Prefab("kq_shrimp", shrimp, assets, shrimp_prefabs),
        Prefab("kq_cookedshrimp", cookedshrimp, assets),
        Prefab("kq_deadshrimp", deadshrimp, assets, deadshrimp_prefabs),
        Prefab("kq_cookeddeadshrimp", deadshrimp_cooked, assets),
        Prefab("kq_shrimphead", shrimphead, assets, shrimphead_prefabs),
        Prefab("kq_steamedshrimphead", steamedshrimphead, assets)