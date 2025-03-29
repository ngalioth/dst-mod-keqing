local assets =
{
    Asset("ANIM", "anim/kq_whitetwigs.zip"),
    Asset("IMAGE", "images/inventoryimages/kq_whitetwigs.tex"),
    Asset("ATLAS", "images/inventoryimages/kq_whitetwigs.xml"),
}

local function onequip(inst, owner) --装备的函数
    owner:AddTag("plantkin")
    owner:AddTag('eyeplant_friend')
    if inst.autotalk == nil then
        inst.autotalk = owner:DoPeriodicTask(0, function ()
            local x, y, z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 8, {"farm_plant"})
            for _, v in ipairs(ents) do
                if v.components.farmplanttendable ~= nil then
                    v.components.farmplanttendable:TendTo(owner)
                end
            end
        end)
    end
end

local function onunequip(inst, owner) --解除装备
    owner:RemoveTag("plantkin")
    owner:RemoveTag('eyeplant_friend')
    if inst.autotalk ~= nil then
        inst.autotalk:Cancel()
        inst.autotalk = nil
    end
end

local function fn()
    local assetname = "kq_whitetwigs"
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(assetname) -- 地上动画
    inst.AnimState:SetBuild(assetname) -- 材质包，就是anim里的zip包
    inst.AnimState:PlayAnimation("idle") -- 默认播放哪个动画

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.autotalk = nil

    inst:AddComponent("inspectable") -- 可检查组件
    inst:AddComponent("inventoryitem") -- 物品组件
    inst.components.inventoryitem.imagename = "kq_whitetwigs"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_whitetwigs.xml" -- 在背包里的贴图

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY -- 护符栏位到底对不对呢？
    return inst
end

return  Prefab("kq_whitetwigs", fn, assets)