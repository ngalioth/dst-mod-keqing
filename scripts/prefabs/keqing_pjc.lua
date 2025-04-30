require("prefabutil")
-- 盘岩结绿
local assets = {
	Asset("ANIM", "anim/greensword.zip"), -- 地上的动画
	Asset("ANIM", "anim/swap_greensword.zip"), -- 手里的动画
	Asset("IMAGE", "images/inventoryimages/greensword.tex"),
	Asset("ATLAS", "images/inventoryimages/greensword.xml"), -- 加载物品栏贴图
}

local function onequip(inst, owner) -- 装备
	owner.AnimState:OverrideSymbol("swap_object", "swap_greensword", "swap_greensword") -- 第三个参数是放动画贴图的文件夹的名字
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	local refinements = inst.components.refinement:GetRefineLevel("keqing_pjc") -- 获取精练等级
	-- 装备时增加装备者的最大生命值20%-40%的位面伤害
	inst.components.planardamage:AddBonus(inst, owner.components.health.maxhealth * (0.15 + refinements * 0.05), "pjc")

	if owner.components.keqing_stats ~= nil then
		owner.components.keqing_stats.crit:SetModifier(inst, 0.441)
	end
end

local function onunequip(inst, owner) -- 解除装备
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")

	inst.components.planardamage:RemoveBonus(inst, "pjc")

	if owner.components.keqing_stats ~= nil then
		owner.components.keqing_stats.crit:RemoveModifier(inst)
	end
end

local function onrefine(inst)
	local greengem_num = inst.components.refinement:GetRefineLevel("greengem")
	local isAccelerated = inst.components.refinement:GetRefineLevel("walrus_tusk")
	local refinelevel = inst.components.refinement:GetRefineLevel("keqing_pjc")
	inst.components.planardamage:SetBaseDamage(greengem_num * 5)
	if isAccelerated == 1 then
		inst.components.equippable.walkspeedmult = 1.25
	else
		inst.components.equippable.walkspeedmult = 1
	end
	local basename = STRINGS.NAMES.KEQING_PJC .. " 精练" .. refinelevel .. "阶"
	local str = "绿" .. greengem_num
	inst.components.named:SetName(basename .. "\n" .. str)
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
	inst:AddTag("nosteal")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("named")

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
	-- inst.components.equippable.restrictedtag = "keqing"
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1 -- 加速
	inst:AddComponent("refinement")
	inst.components.refinement:AddRefineable("greengem", 0, nil)
	inst.components.refinement:AddRefineable("walrus_tusk", 0, 1)
	inst.components.refinement:AddRefineable("keqing_pjc", 1, 5)
	inst.components.refinement:SetOnRefine(onrefine)

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("keqing_pjc", fn, assets)
