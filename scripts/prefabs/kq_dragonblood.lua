local assets =
{
    Asset("ANIM", "anim/kq_dragonblood.zip"),
    Asset("IMAGE", "images/inventoryimages/kq_dragonblood.tex"),
    Asset("ATLAS", "images/inventoryimages/kq_dragonblood.xml"),
}

local function DoPercentDmg(inst, attacker)
    if attacker.target ~= nil then
        local target = attacker.target
        if inst ~= nil and inst.components ~= nil and inst.components.inventory ~= nil then
			if target.components.health ~= nil then
                target.components.health:DoDelta(-target.components.health.maxhealth * 0.002, nil, inst.prefab, nil, inst, true)
            end
        end
	end
end

local function onequip(inst, owner) --装备的函数
    owner:ListenForEvent("onhitother", DoPercentDmg)
end

local function onunequip(inst, owner) --解除装备
    owner:RemoveEventCallback("onhitother", DoPercentDmg)
end

local function fn()
    local assetname = "kq_dragonblood"
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
    inst.components.inventoryitem.imagename = "kq_dragonblood"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_dragonblood.xml" -- 在背包里的贴图

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY -- 护符栏位到底对不对呢？
    return inst
end

return  Prefab("kq_dragonblood", fn, assets)