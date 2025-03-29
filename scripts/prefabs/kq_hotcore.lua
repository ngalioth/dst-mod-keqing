local assets =
{
    Asset("ANIM", "anim/kq_hotcore.zip"),
    Asset("IMAGE", "images/inventoryimages/kq_hotcore.tex"),
    Asset("ATLAS", "images/inventoryimages/kq_hotcore.xml"),
}

local function onequip(inst, owner) --装备的函数
    owner.components.health.fire_damage_scale = 0
    owner.components.temperature:SetFreezingHurtRate(0)
end

local function onunequip(inst, owner) --解除装备
    owner.components.health.fire_damage_scale = 1
    local hurtrate = TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME
    owner.components.temperature:SetFreezingHurtRate(hurtrate)
end

local function fn()
    local assetname = "kq_hotcore"
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

    inst:AddComponent("inspectable") -- 可检查组件
    inst:AddComponent("inventoryitem") -- 物品组件
    inst.components.inventoryitem.imagename = "kq_hotcore"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_hotcore.xml" -- 在背包里的贴图

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY -- 护符栏位到底对不对呢？

    return inst
end

return  Prefab("kq_hotcore", fn, assets)