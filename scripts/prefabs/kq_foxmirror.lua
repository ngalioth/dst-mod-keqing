local assets =
{
    Asset("ANIM", "anim/kq_foxmirror.zip"),
    Asset("IMAGE", "images/inventoryimages/kq_foxmirror.tex"),
    Asset("ATLAS", "images/inventoryimages/kq_foxmirror.xml"),
}

local function DoRealDmg(inst, attacker)
    if attacker.target ~= nil then
        local target = attacker.target
        if inst ~= nil and inst.components ~= nil and inst.components.inventory ~= nil then
            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) -- 获取攻击者手持的武器
            local damage = 10
			if weapon then
                if weapon.components.weapon then
                    damage = weapon.components.weapon:GetDamage(inst, nil) * 0.5 or 0
                end
                if target.components.health ~= nil then
                    target.components.health:DoDelta(-damage, nil, inst.prefab, nil, inst, true)
				end
            end
        end
	end
end

local function onequip(inst, owner) --装备的函数
    owner:ListenForEvent("onhitother", DoRealDmg)
end

local function onunequip(inst, owner) --解除装备
    owner:RemoveEventCallback("onhitother", DoRealDmg)
end

local function fn()
    local assetname = "kq_foxmirror"
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
    inst.components.inventoryitem.imagename = "kq_foxmirror"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_foxmirror.xml" -- 在背包里的贴图

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY -- 护符栏位到底对不对呢？
    return inst
end

return  Prefab("kq_foxmirror", fn, assets)