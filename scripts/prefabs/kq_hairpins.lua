local assets = {
	Asset("ANIM", "anim/kq_hairpins.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_hairpins.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_hairpins.xml"),
}

local prefabs = { "light" }

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

local function DoPercentDmg(inst, attacker)
	if attacker.target ~= nil then
		local target = attacker.target
		if inst ~= nil and inst.components ~= nil and inst.components.inventory ~= nil then
			if target.components.health ~= nil then
				target.components.health:DoDelta(
					-target.components.health.maxhealth * 0.002,
					nil,
					inst.prefab,
					nil,
					inst,
					true
				)
			end
		end
	end
end

local function onequip(inst, owner) -- 装备的函数
	if not (owner:HasTag("keqing") or owner:HasTag("kokomi")) then
		if owner.components.talker then
			owner.components.talker:Say("我不能装备这个。")
		end
		inst.Transform:SetPosition(owner.Transform:GetWorldPosition())
		inst.components.inventoryitem:OnDropped(true)
		return
	end
	if inst["lightstone"] == 1 then -- 发光
		inst.light = SpawnPrefab("light")
		inst.light.entity:SetParent(owner.entity)
	end
	if inst["waterelec"] == 1 then -- 防水防雷（？）
		inst.components.waterproofer:SetEffectiveness(1) -- 防雨
		inst.components.equippable.insulated = true
	end
	if inst["acce"] == 1 then -- 加速
		inst.components.equippable.walkspeedmult = 1.25
	end
	if inst["cold"] == 1 then -- 防过冷
		owner.components.temperature.mintemp = 10
	end
	if inst["hot"] == 1 then -- 防过热
		owner.components.temperature.mintemp = 60
	end
	if inst["colddam"] == 1 then -- 防冻伤
		inst:AddTag("kq_antifreeze")
		owner.components.temperature:SetFreezingHurtRate(0)
	end
	if inst["hotdam"] == 1 then -- 防热死
		owner.components.health.fire_damage_scale = 0
		owner.components.temperature:SetOverheatHurtRate(0)
	end
	if inst["realdmg"] == 1 then -- 真伤
		owner:ListenForEvent("onhitother", DoRealDmg)
	end
	if inst["nohit"] == 1 then -- 防击飞和地皮减速（？）
		inst:AddTag("heavyarmor")
		inst.components.armor:InitIndestructible(0.90)
		inst.components.planardefense:SetBaseDefense(20)
		owner.components.locomotor:SetSlowMultiplier(1)
	end
	if inst["nodust"] == 1 then -- 防沙尘暴等
		inst:AddTag("goggles")
	end
	if inst["ghostfriendly"] == 1 then -- 鬼魂友好
		owner.components.sanity:AddSanityAuraImmunity("ghost")
		owner.components.sanity:SetPlayerGhostImmunity(true)
		-- owner.components.sanity.neg_aura_mult = 0.5 -- Deprecated, use the SourceModifier below
		owner.components.sanity.neg_aura_modifiers:SetModifier(inst, 0.5, "neg_aura_mult") -- 不会用思密达
	end
	if inst["talk"] == 1 then
		owner:AddTag("plantkin")
		owner:AddTag("eyeplant_friend")
		if inst.autotalk == nil then
			inst.autotalk = owner:DoPeriodicTask(0, function()
				local x, y, z = owner.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 8, { "farm_plant" })
				for _, v in ipairs(ents) do
					if v.components.farmplanttendable ~= nil then
						v.components.farmplanttendable:TendTo(owner)
					end
				end
			end)
		end
	end
	if inst["percdmg"] == 1 then -- 真伤
		owner:ListenForEvent("onhitother", DoPercentDmg)
	end
end

local function onunequip(inst, owner) -- 解除装备
	if not (owner:HasTag("keqing") or owner:HasTag("kokomi")) then
		return
	end
	local hurtrate = TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME
	if inst["lightstone"] == 1 then
		if inst.light ~= nil then
			inst.light:Remove()
		end
	end
	owner.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
	owner.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
	if inst["colddam"] == 1 then -- 防冻伤
		owner.components.temperature:SetFreezingHurtRate(hurtrate)
	end
	if inst["hotdam"] == 1 then -- 防热死
		owner.components.health.fire_damage_scale = 1
		owner.components.temperature:SetOverheatHurtRate(hurtrate)
	end
	if inst["realdmg"] == 1 then
		owner:RemoveEventCallback("onhitother", DoRealDmg)
	end
	if inst["nohit"] == 1 then -- 防击飞和减速（？）
		owner.components.locomotor:SetSlowMultiplier(0.6)
	end
	if inst["ghostfriendly"] == 1 then -- 鬼魂友好
		owner.components.sanity:AddSanityAuraImmunity("ghost") -- 防止直接塞进装备状态的发簪导致卸下崩溃
		owner.components.sanity:RemoveSanityAuraImmunity("ghost")
		owner.components.sanity:SetPlayerGhostImmunity(false)
		-- owner.components.sanity.neg_aura_mult = 1 -- Deprecated, use the SourceModifier below
		owner.components.sanity.neg_aura_modifiers:SetModifier(inst, 0.5, "neg_aura_mult") -- 不会用思密达
	end
	if inst["talk"] == 1 then
		owner:RemoveTag("plantkin")
		owner:RemoveTag("eyeplant_friend")
		if inst.autotalk ~= nil then
			inst.autotalk:Cancel()
			inst.autotalk = nil
		end
	end
	if inst["percdmg"] == 1 then
		owner:RemoveEventCallback("onhitother", DoPercentDmg)
	end
end

-- local function ongiveitem(inst, item, owner)
--     local have = "已有："
--     local nothave = "还没有："
--     if item then
--         if inst["lightstone"] == 1 then
--             have = have .. "流明石触媒 "
--             if item.prefab == "kq_lightstone" then -- 发光
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "流明石触媒 "
--             if item.prefab == "kq_lightstone" then -- 发光
--                 inst["lightstone"] = math.min(inst["lightstone"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["waterelec"] == 1 then
--             have = have .. "奇特的羽毛 "
--             if item.prefab == "kq_elecfur" then -- 防雨防雷
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "奇特的羽毛 "
--             if item.prefab == "kq_elecfur" then -- 防雨防雷
--                 inst["waterelec"] = math.min(inst["waterelec"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["acce"] == 1 then
--             have = have .. "红羽团扇 "
--             if item.prefab == "kq_redfun" then -- 加速
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "红羽团扇 "
--             if item.prefab == "kq_redfun" then -- 加速
--                 inst["acce"] = math.min(inst["acce"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["cold"] == 1 then
--             have = have .. "放热瓶 "
--             if item.prefab == "kq_hotbottle" then -- 防过冷
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "放热瓶 "
--             if item.prefab == "kq_hotbottle" then -- 防过冷
--                 inst["cold"] = math.min(inst["cold"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["hot"] == 1 then
--             have = have .. "制冷瓶(无法获得) "
--             if item.prefab == "kq_coldbottle" then -- 防过热
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "制冷瓶(无法获得) "
--             if item.prefab == "kq_coldbottle" then -- 防过热
--                 inst["hot"] = math.min(inst["hot"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["colddam"] == 1 then
--             have = have .. "常燃火种 "
--             if item.prefab == "kq_hotcore" then -- 防冻伤
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "常燃火种 "
--             if item.prefab == "kq_hotcore" then -- 防冻伤
--                 inst["colddam"] = math.min(inst["colddam"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["hotdam"] == 1 then
--             have = have .. "极寒之核 "
--             if item.prefab == "kq_coldcore" then -- 防热死
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "极寒之核 "
--             if item.prefab == "kq_coldcore" then -- 防热死
--                 inst["hotdam"] = math.min(inst["hotdam"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["realdmg"] == 1 then
--             have = have .. "留念镜 "
--             if item.prefab == "kq_foxmirror" then -- 真伤
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "留念镜 "
--             if item.prefab == "kq_foxmirror" then -- 真伤
--                 inst["realdmg"] = math.min(inst["realdmg"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["nohit"] == 1 then
--             have = have .. "镇石断片 "
--             if item.prefab == "kq_splitrock" then -- 防击飞
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "镇石断片 "
--             if item.prefab == "kq_splitrock" then -- 防击飞
--                 inst["nohit"] = math.min(inst["nohit"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["nodust"] == 1 then
--             have = have .. "捕风瓶 "
--             if item.prefab == "kq_windbottle" then -- 防沙尘暴等
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "捕风瓶 "
--             if item.prefab == "kq_windbottle" then -- 防沙尘暴等
--                 inst["nodust"] = math.min(inst["nodust"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["ghostfriendly"] == 1 then
--             have = have .. "戴丧面具 "
--             if item.prefab == "kq_ladytomb" then -- 鬼魂友好
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "戴丧面具 "
--             if item.prefab == "kq_ladytomb" then -- 鬼魂友好
--                 inst["ghostfriendly"] = math.min(inst["ghostfriendly"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["talk"] == 1 then
--             have = have .. "初生白枝 "
--             if item.prefab == "kq_whitetwigs" then -- 植物友好，自动对话
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "初生白枝 "
--             if item.prefab == "kq_whitetwigs" then -- 植物友好，自动对话
--                 inst["talk"] = math.min(inst["talk"] + 1, 1)
--                 return true
--             end
--         end
--         if inst["percdmg"] == 1 then
--             have = have .. "深邃之血 "
--             if item.prefab == "kq_dragonblood" then -- 百分比伤害
--                 owner.components.talker:Say("里面已经有一个了。")
--                 return false
--             end
--         else
--             nothave = nothave .. "深邃之血 "
--             if item.prefab == "kq_dragonblood" then -- 百分比伤害
--                 inst["percdmg"] = math.min(inst["percdmg"] + 1, 1)
--                 return true
--             end
--         end
--     end
--     if owner.components.talker then
--         owner.components.talker:Say(have .. "\n" .. nothave)
--     end
--     return false
-- end

local function onsave(inst, data)
	data["lightstone"] = inst["lightstone"] or 0
	data["waterelec"] = inst["waterelec"] or 0
	data["acce"] = inst["acce"] or 0
	data["cold"] = inst["cold"] or 0
	data["colddam"] = inst["colddam"] or 0
	data["hot"] = inst["hot"] or 0
	data["hotdam"] = inst["hotdam"] or 0
	data["nohit"] = inst["nohit"] or 0
	data["realdmg"] = inst["realdmg"] or 0
	data["nodust"] = inst["nodust"] or 0
	data["ghostfriendly"] = inst["ghostfriendly"] or 0
	data["talk"] = inst["talk"] or 0
	data["percdmg"] = inst["percdmg"] or 0
end

local function onload(inst, data)
	if data ~= nil then
		if data["lightstone"] then
			inst["lightstone"] = data["lightstone"] or 0
		end
		if data["waterelec"] then
			inst["waterelec"] = data["waterelec"] or 0
		end
		if data["acce"] then
			inst["acce"] = data["acce"] or 0
		end
		if data["cold"] then
			inst["cold"] = data["cold"] or 0
		end
		if data["colddam"] then
			inst["colddam"] = data["colddam"] or 0
		end
		if data["hot"] then
			inst["hot"] = data["hot"] or 0
		end
		if data["hotdam"] then
			inst["hotdam"] = data["hotdam"] or 0
		end
		if data["nohit"] then
			inst["nohit"] = data["nohit"] or 0
		end
		if data["realdmg"] then
			inst["realdmg"] = data["realdmg"] or 0
		end
		if data["nodust"] then
			inst["nodust"] = data["nodust"] or 0
		end
		if data["ghostfriendly"] then
			inst["ghostfriendly"] = data["ghostfriendly"] or 0
		end
		if data["talk"] then
			inst["talk"] = data["talk"] or 0
		end
		if data["percdmg"] then
			inst["percdmg"] = data["percdmg"] or 0
		end
	end
end

local function fn()
	local inst = CreateEntity()
	local assetname = "kq_hairpins"

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.OnSave = onsave
	inst.OnLoad = onload

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst["lightstone"] = 0 -- 发光
	inst["cold"] = 0 -- 过冷
	inst["colddam"] = 0 -- 冻伤
	inst["hot"] = 0 -- 过热
	inst["hotdam"] = 0 -- 热掉血
	inst["waterelec"] = 0 -- 防雨防雷
	inst["nohit"] = 0 -- 防击飞
	inst["acce"] = 0 -- 加速
	inst["realdmg"] = 0 -- 真伤
	inst["nodust"] = 0 -- 防沙尘暴等
	inst["ghostfriendly"] = 0 -- 鬼魂友好
	inst["talk"] = 0 -- 植物友好，自动对话
	inst["percdmg"] = 0 -- 百分比伤害

	inst.light = nil
	inst.autotalk = nil
	inst:AddTag("nosteal") -- 防偷取
	inst:AddTag("hide_percentage") -- 隐藏百分比

	inst:AddComponent("inspectable") -- 可以检查
	inst:AddComponent("inventoryitem") -- 物品
	inst.components.inventoryitem.imagename = "kq_hairpins"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_hairpins.xml"
	inst.components.inventoryitem.cangoincontainer = true

	inst:AddComponent("armor") -- 护甲
	inst.components.armor:InitIndestructible(0.50)

	inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(0)

	inst:AddComponent("waterproofer") -- 防水
	inst.components.waterproofer:SetEffectiveness(0)

	inst:AddComponent("equippable") -- 可装备
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	-- inst.components.equippable.restrictedtag = "keqing"
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	MakeHauntableLaunch(inst)
	return inst
end

local function lightfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Light:SetRadius(4)
	inst.Light:SetFalloff(0.75)
	inst.Light:SetIntensity(0.65)
	inst.Light:SetColour(255 / 255, 255 / 255, 255 / 255)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

return Prefab("kq_hairpins", fn, assets, prefabs), Prefab("light", lightfn)
