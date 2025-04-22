require("prefabutil")

local assets = {
	Asset("ANIM", "anim/greensword.zip"), -- 地上的动画
	Asset("ANIM", "anim/swap_greensword.zip"), -- 手里的动画
	Asset("IMAGE", "images/inventoryimages/greensword.tex"),
	Asset("ATLAS", "images/inventoryimages/greensword.xml"), -- 加载物品栏贴图
}

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "player", "chester" }

local function onequip(inst, owner) -- 装备
	owner.AnimState:OverrideSymbol("swap_object", "swap_greensword", "swap_greensword") -- 第三个参数是放动画贴图的文件夹的名字
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	if owner.prefab == "keqing" then
		if owner.components.talker then
			owner.components.talker:Say("速战速决！")
		end
		inst.components.planardamage:SetBaseDamage(
			owner.components.health.maxhealth * (0.2 + inst["greengemnum"] * 0.02)
		)
	end
	if owner.components.stats_manager ~= nil then
		owner.components.stats_manager.crit:SetModifier(inst, 0.441)
	end
end

local function onunequip(inst, owner) -- 解除装备
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	-- if owner.components.combat.external_critical_rate_multipliers ~= nil then
	-- 	owner.components.combat.external_critical_rate_multipliers:RemoveModifier(inst)
	-- end
	if owner.components.stats_manager ~= nil then
		owner.components.stats_manager.crit:RemoveModifier(inst)
	end
end

local function ongiveitem(inst, item, owner)
	if item then
		if item.prefab == "greengem" then
			inst["greengemnum"] = inst["greengemnum"] + 1
			owner.components.talker:Say("当前已放入绿宝石数量：" .. tostring(inst["greengemnum"]))
			return true
		end
		if item.prefab == "walrus_tusk" then
			if inst["accelerate"] == 1 then
				if owner.components.talker then
					owner.components.talker:Say("移速加成已达到最大！")
				end
				return false
			else
				inst["accelerate"] = math.min(inst["accelerate"] + 1, 1)
				return true
			end
		end
	end
	if owner.components.talker then
		owner.components.talker:Say("我不能那样做。")
	end
	return false
end

local function bonus(inst, owner)
	inst.components.weapon:SetDamage(52 + inst["greengemnum"] * 5)
	inst.components.planardamage:SetBaseDamage(owner.components.health.maxhealth * (0.2 + inst["greengemnum"] * 0.02))
	inst.components.equippable.walkspeedmult = 1 + 0.25 * inst["accelerate"] --加速
end

local function onsave(inst, data)
	data["greengemnum"] = inst["greengemnum"] or 0
	data["accelerate"] = inst["accelerate"] or 0
end

local function onload(inst, data)
	if data ~= nil then
		if data["greengemnum"] then
			inst["greengemnum"] = data["greengemnum"] or 0
		end
		if data["accelerate"] then
			inst["accelerate"] = data["accelerate"] or 0
		end
	end
	inst.components.weapon:SetDamage(52 + inst["greengemnum"] * 5)
	inst.components.equippable.walkspeedmult = 1 + 0.25 * inst["accelerate"] --加速
end

-- function Combat:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
local function onattack(inst, attacker, target)
	--if (target.components.burnable ~= nil) then -- 判断目标是否可燃  否则攻击不可燃目标会闪退
	--target.components.burnable:Ignite(nil, attacker) -- 让目标燃起来
	--end
	-- 获取被攻击对象的世界坐标
	local x, y, z = target.Transform:GetWorldPosition()
	-- 通过 TheSim:FindEntities() 函数查找周围的实体
	local ents = TheSim:FindEntities(x, y, z, 3, { "_combat" }, exclude_tags)
	-- 遍历找到的实体
	for i, ent in ipairs(ents) do
		-- 对找到的实体再次的过滤
		local damage = inst.components.weapon:GetDamage(attacker, ent)
		if not (ent and ent.components.follower and ent.components.follower.leader == attacker) then
			if ent ~= target and ent.components.combat then
				attacker:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = nil })
				ent.components.combat:GetAttacked(attacker, damage, inst, nil)
			end
		end
	end
end

--状态写法，但是总是有bug
local function onspell(inst, target, mousepos)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local riding = owner.components.rider and owner.components.rider:IsRiding()
	if not riding then
		owner.sg:GoToState("kq_charge", mousepos)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.OnSave = onsave
	inst.OnLoad = onload
	MakeInventoryPhysics(inst)

	inst["greengemnum"] = 0
	inst["accelerate"] = 0

	inst.AnimState:SetBank("greensword") --地上动画
	inst.AnimState:SetBuild("greensword")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp") --武器的标签跟攻击方式跟攻击音效有关 没有特殊的话就用这两个
	inst:AddTag("pointy")
	inst:AddTag("greensword")
	inst:AddTag("genshin_sword")
	inst:AddTag("nosteal")

	-- 元素反应兼容
	inst:AddTag("subtextweapon")
	inst.subtext = "crit_rate"
	inst.subnumber = "44.1%"
	inst.description = "武器提高等同于装备者生命值上限20%+放入绿宝石数×5%的位面伤害。"

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable") -- 可检查组件

	inst:AddComponent("inventoryitem") --物品组件
	inst.components.inventoryitem.imagename = "greensword"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/greensword.xml" --物品贴图

	inst:AddComponent("weapon") -- 增加武器组件 有了这个才可以打人
	inst.components.weapon:SetDamage(52)
	inst.components.weapon:SetRange(1.5)
	inst.components.weapon:SetOnAttack(onattack)

	inst:AddComponent("planardamage") --位面伤害
	inst.components.planardamage:SetBaseDamage(0)

	--- no longer used
	-- inst:AddComponent("kq_crit")
	-- inst.components.kq_crit:SetCrit(0.441)
	-- inst.components.kq_crit:SetCritdmg(0)

	inst:AddComponent("trader") -- 可塞物品
	inst.components.trader:SetAcceptTest(ongiveitem)
	inst.components.trader.acceptnontradable = true
	inst.components.trader.onaccept = bonus

	inst:AddComponent("equippable") -- 可装备组件
	inst.components.equippable.restrictedtag = "keqing"
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1 --加速

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("greensword", fn, assets)
