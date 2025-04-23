--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

-- local function IsStringDirty(inst)
-- 	return inst.sound_override:value() > 0
-- end

-- local function OnSayDirty(inst)
-- 	if inst._parent ~= nil and IsStringDirty(inst) then
-- 		local list = STRING_LISTS[inst.string_list:value()]
-- 		local string = list ~= nil and list[inst.string_id:value()] or nil
-- 		if string ~= nil then
-- 			inst._parent.components.talker:Say(string, nil, nil, nil, true)
-- 		end
-- 	end
-- end

-- local function GetTalkSound(inst)
-- 	return TALK_SOUNDS[inst.sound_override:value()]
-- end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

-- 这是处理lucy在手上和其他地方的时候，只有在手上时才attach classified 我应该不需要

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------
--Triggered on clients immediately after initial deserialization of tags from construction
local function OnRemoveEntity(inst)
	if inst._parent ~= nil then
		inst._parent.keqing_classified = nil
	end
end
local function OnEntityReplicated(inst)
	inst._parent = inst.entity:GetParent()
	if inst._parent == nil then
		moderror("Unable to initialize classified data for keqing", level)

		--- 实际上客户端由于classifedTarget的设置，只能由classified主动调用parent的attach
		-- 这里尝试调用parent的 cmp:AttachClassified 我这里默认是keqing cmp
	else
		--- 由于需要绑定过多组件，延迟0s保证生效
		inst:DoStaticTaskInTime(0, function(inst)
			-- 这里分别调用对应组件的AttachClassified
			for i, v in ipairs({ "keqing", "elemental_burst" }) do
				print("Try to attach classified to parent component: " .. v)
				inst._parent:TryAttachClassifiedToReplicaComponent(inst, v)
			end
			inst._parent.keqing_classified = inst
		end)
		-- 客户端replicate时主动调用parent组件的AttachClassified 必须
		inst.OnRemoveEntity = OnRemoveEntity
	end
end

--------------------------------------------------------------------------

local function RegisterNetListeners(inst)
	-- inst:ListenForEvent("saydirty", OnSayDirty)
	-- -- 大概是第一次装备时？
	-- OnSayDirty(inst)
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	if TheWorld.ismastersim then
		inst.entity:AddTransform() --So we can follow parent's sleep state
	end
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:Hide()
	inst:AddTag("CLASSIFIED")

	inst.is_dash_enabled = net_bool(inst.GUID, "keqing_classified.is_dash_enabled", "is_dash_enabled_dirty")

	inst.crit = net_float(inst.GUID, "keqing_classified.crit", "crit_dirty")
	inst.crit_dmg = net_float(inst.GUID, "keqing_classified.crit_dmg", "crit_dmg_dirty")
	inst.bonus = net_float(inst.GUID, "keqing_classified.bonus", "bonus_dirty")

	-- 元素爆发变量 最大能量 当前能量 最大cd 当前cd
	inst.burst_cd = net_float(inst.GUID, "keqing_classified.burst_cd", "burst_cd_dirty")
	inst.burst_current_cd = net_float(inst.GUID, "keqing_classified.burst_current_cd", "burst_current_cd_dirty")
	inst.burst_energy = net_float(inst.GUID, "keqing_classified.burst_energy", "burst_energy_dirty")
	inst.burst_current_energy =
		net_float(inst.GUID, "keqing_classified.burst_current_energy", "burst_current_energy_dirty")

	-- 元素战技 战技的cd和当前cd以及是否为二段
	inst.skill_cd = net_float(inst.GUID, "keqing_classified.skill_cd", "skill_cd_dirty")
	inst.skill_current_cd = net_float(inst.GUID, "keqing_classified.skill_current_cd", "skill_current_cd_dirty")
	inst.skill_state = net_bool(inst.GUID, "keqing_classified.skill_state", "skill_state_dirty")

	-- inst.string_list = net_smallbyte(inst.GUID, "keqing_classified.string_list")
	-- inst.string_id = net_smallbyte(inst.GUID, "keqing_classified.string_id")
	-- inst.sound_override = net_tinybyte(inst.GUID, "keqing_classified.sound_override", "saydirty")
	-- inst.enabled = false

	inst.entity:SetPristine()

	--Common interface

	--- 客户端注册事件监听，响应变量变化
	if not TheWorld.ismastersim then
		--Client interface
		inst.OnEntityReplicated = OnEntityReplicated

		--Delay net listeners until after initial values are deserialized
		inst:DoStaticTaskInTime(0, RegisterNetListeners)

		return inst
	end

	--Server interface

	return inst
end

return Prefab("keqing_classified", fn)
