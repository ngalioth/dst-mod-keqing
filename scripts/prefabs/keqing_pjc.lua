require "prefabutil"

local assets = {Asset("ANIM", "anim/greensword.zip"), -- 地上的动画
Asset("ANIM", "anim/swap_greensword.zip"), -- 手里的动画
Asset("IMAGE", "images/inventoryimages/greensword.tex"), Asset("ATLAS", "images/inventoryimages/greensword.xml") -- 加载物品栏贴图
}

local exclude_tags = {"INLIMBO", "companion", "wall", "abigail", "player", "chester"}

local function onequip(inst, owner) -- 装备
    owner.AnimState:OverrideSymbol("swap_object", "swap_greensword", "swap_greensword") -- 第三个参数是放动画贴图的文件夹的名字
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if owner.components.damage_bonus_manager ~= nil then
        owner.components.damage_bonus_manager.crit:SetModifier(inst, 0.441)
    end
end

local function onunequip(inst, owner) -- 解除装备
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    if owner.components.damage_bonus_manager ~= nil then
        owner.components.damage_bonus_manager.crit:RemoveModifier(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("greensword") -- 地上动画
    inst.AnimState:SetBuild("greensword")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp") -- 武器的标签跟攻击方式跟攻击音效有关 没有特殊的话就用这两个
    inst:AddTag("pointy")
    inst:AddTag("greensword")
    inst:AddTag("genshin_sword")
    inst:AddTag("nosteal")

    -- 元素反应兼容
    inst:AddTag("subtextweapon")
    inst.subtext = "crit_rate"
    inst.subnumber = "44.1%"
    inst.description = "护国的无垢之心"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable") -- 可检查组件

    inst:AddComponent("inventoryitem") -- 物品组件
    inst.components.inventoryitem.imagename = "greensword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/greensword.xml" -- 物品贴图

    inst:AddComponent("weapon") -- 增加武器组件 有了这个才可以打人
    inst.components.weapon:SetDamage(100)
    inst.components.weapon:SetRange(1.5)
    -- inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("planardamage") -- 位面伤害
    inst.components.planardamage:SetBaseDamage(0)

    inst:AddComponent("equippable") -- 可装备组件
    inst.components.equippable.restrictedtag = "keqing"
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1 -- 加速

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("keqing_pjc", fn, assets)
