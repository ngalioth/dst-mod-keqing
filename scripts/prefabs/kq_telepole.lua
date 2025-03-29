require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/kq_telepole.zip"), -- 地上的动画
    Asset("ANIM", "anim/kq_swap_telepole.zip"), -- 手里的动画
    Asset("IMAGE", "images/inventoryimages/kq_telepole.tex"),
    Asset("ATLAS", "images/inventoryimages/kq_telepole.xml"), -- 加载物品栏贴图
}

local function onequip(inst, owner) -- 装备
    owner.AnimState:OverrideSymbol("swap_object", "kq_swap_telepole", "kq_swap_telepole") -- 第三个参数是放动画贴图的文件夹的名字
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner) -- 解除装备
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onsave(inst, data)
    
end

local function onload(inst, data)
    
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.OnSave = onsave
    inst.OnLoad = onload
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kq_telepole") --地上动画
    inst.AnimState:SetBuild("kq_telepole")
	inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp") --武器的标签跟攻击方式跟攻击音效有关 没有特殊的话就用这两个
    inst:AddTag("pointy")
    inst:AddTag("kq_telepole")
    inst:AddTag("nosteal")
    inst:AddTag("wateringcan")
    inst:AddTag("allow_action_on_impassable") -- ？

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable") -- 可检查组件

    inst:AddComponent("inventoryitem") --物品组件
    inst.components.inventoryitem.imagename = "kq_telepole"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_telepole.xml" --物品贴图

    inst:AddComponent("weapon") -- 增加武器组件 有了这个才可以打人
    inst.components.weapon:SetDamage(51)
    inst.components.weapon:SetRange(1)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.MULTITOOL_AXE_PICKAXE_EFFICIENCY) -- 斧子
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.MULTITOOL_AXE_PICKAXE_EFFICIENCY) -- 镐子
    inst.components.tool:SetAction(ACTIONS.DIG) -- 铲子
    inst.components.tool:SetAction(ACTIONS.HAMMER) -- 锤子
    inst.components.tool:SetAction(ACTIONS.NET) -- 捕虫网
    inst.components.tool:EnableToughWork(true) -- 能解除疯猪封印

    inst:AddComponent("fishingrod") -- 淡水钓竿
    inst:AddComponent("farmtiller") -- 园艺锄

    inst:AddComponent("oar") -- 桨，照搬邪天翁喙的数据
    inst.components.oar.force = 0.8
    inst.components.oar.ROW_FAIL_WEAR = 6
    inst.components.oar.ATTACKWEAR = 6
    inst.components.oar.MAX_VELOCITY = 5

    inst:AddComponent("wateryprotection") -- 浇水壶
	inst.components.wateryprotection.extinguishheatpercent = TUNING.WATERINGCAN_EXTINGUISH_HEAT_PERCENT -- 灭火百分比（默认-1）
	inst.components.wateryprotection.temperaturereduction = TUNING.WATERINGCAN_TEMP_REDUCTION -- 降温数值（默认5）
	inst.components.wateryprotection.witherprotectiontime = TUNING.WATERINGCAN_PROTECTION_TIME
	inst.components.wateryprotection.addwetness = 4 * TUNING.PREMIUMWATERINGCAN_WATER_AMOUNT
	inst.components.wateryprotection.protection_dist = TUNING.WATERINGCAN_PROTECTION_DIST
	inst.components.wateryprotection:AddIgnoreTag("player")

    inst:AddComponent("spellcaster")--施法者组件  鼠标右键使用
	--inst.components.spellcaster:SetSpellFn(onspell)  --绑定方法
    --inst.components.spellcaster:SetCanCastFn(cancastfn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canuseondead = true
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseonpoint_water = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster.veryquickcast = true

    --inst:AddComponent("finiteuses") -- 添加有限耐久组件，按次数算
    --inst.components.finiteuses:SetMaxUses(1) -- 设置最大耐久MaxUse
    --inst.components.finiteuses:SetUses(1) -- 设置当前耐久CanUse
    --if inst.components.finiteuses.current < 0 then
        --inst.components.finiteuses.current = 0
    --end
    --inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("equippable") -- 可装备组件
    --inst.components.equippable.restrictedtag = "keqing"
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.25 --加速

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("kq_telepole", fn, assets)