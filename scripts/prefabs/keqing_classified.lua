--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------
-- 客户端不进行其他操作，仅发送RPC

--Triggered on clients immediately after initial deserialization of tags from construction
local function OnRemoveEntity(inst)
	if inst._parent ~= nil then
		inst._parent.keqing_classified = nil
	end
end
local function OnEntityReplicated(inst)
	inst._parent = inst.entity:GetParent()
	if inst._parent == nil then
		moderror("Unable to initialize classified data for keqing")
		--- 实际上客户端由于classifedTarget的设置，只能由classified主动调用parent的attach
	else
		--- 由于需要绑定过多组件，延迟0s保证生效
		inst:DoStaticTaskInTime(0, function(inst)
			-- 这里分别调用对应组件的AttachClassified
			for i, v in ipairs({ "keqing", "burst", "skill" }) do
				modprint("Try to attach classified to parent component: " .. v)
				inst._parent:TryAttachClassifiedToReplicaComponent(inst, v)
			end
			inst._parent.keqing_classified = inst
		end)
		-- 客户端replicate时主动调用parent组件的AttachClassified 必须
		inst.OnRemoveEntity = OnRemoveEntity
	end
end
--------------------------------------------------------------------------

--------------------------------------------------------------------------

-- burst_cd_dirty就对本地的parent推送 burst_cd_delta事件，主机组件内部一样，完成同步
local function makeOnDirty(cmp, name)
	return function(inst)
		if inst._parent then
			local parent = inst._parent
			parent:PushEvent(cmp .. "_" .. name .. "_delta", inst[cmp .. "_" .. name]:value())
		end
	end
end
--------------------------------------------------------------------------
local function OnInitialDirtyStates(inst) end

local function RegisterNetListeners_mastersim(inst) end

local function RegisterNetListeners_local(inst)
	--- for burst
	inst:ListenForEvent("burst_level_dirty", makeOnDirty("burst", "level"))
	inst:ListenForEvent("burst_cd_dirty", makeOnDirty("burst", "cd"))
	inst:ListenForEvent("burst_maxcd_dirty", makeOnDirty("burst", "maxcd"))
	inst:ListenForEvent("burst_energy_dirty", makeOnDirty("burst", "energy"))
	inst:ListenForEvent("burst_maxenergy_dirty", makeOnDirty("burst", "maxenergy"))
	--- for skill
	inst:ListenForEvent("skill_level_dirty", makeOnDirty("skill", "level"))
	inst:ListenForEvent("skill_cd_dirty", makeOnDirty("skill", "cd"))
	inst:ListenForEvent("skill_maxcd_dirty", makeOnDirty("skill", "maxcd"))
	inst:ListenForEvent("skill_state_dirty", makeOnDirty("skill", "state"))
end

local function RegisterNetListeners_common(inst) end

local function RegisterNetListeners(inst)
	if TheWorld.ismastersim then
		inst._parent = inst.entity:GetParent()
		RegisterNetListeners_mastersim(inst)
	else
		RegisterNetListeners_local(inst)
	end

	RegisterNetListeners_common(inst)

	OnInitialDirtyStates(inst)

	if inst._parent.isseamlessswaptarget then
		--finishseamlessplayerswap will be able to retrigger all the instant events if the initialization happened in the "wrong"" order.
		inst:ListenForEvent("finishseamlessplayerswap", fns.FinishSeamlessPlayerSwap, inst._parent)
		--Fade is initialized by OnPlayerActivated in gamelogic.lua
	end
end

--------------------------------------------------------------------------

local burstVar = {
	"cd",
	"maxcd",
	"energy",
	"maxenergy",
}
local skillVar = {
	"cd",
	"maxcd",
}

local function fn()
	local inst = CreateEntity()

	if TheWorld.ismastersim then
		inst.entity:AddTransform() --So we can follow parent's sleep state
	end
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	inst.entity:Hide()
	inst:AddTag("CLASSIFIED")
	-- 是否开启冲刺
	inst.sprint = net_bool(inst.GUID, "keqing.sprint", "sprint_dirty")

	-- 是否开启语音
	inst.audio = net_bool(inst.GUID, "keqing.audio", "audio_dirty")

	-- 元素爆发 等级 cd 当前cd 最大能量 当前能量
	for _, v in ipairs(burstVar) do
		inst["burst_" .. v] = net_float(inst.GUID, "burst." .. v, "burst_" .. v .. "_dirty")
	end
	inst.burst_level = net_ushortint(inst.GUID, "burst.level", "burst_level_dirty")

	-- 元素战技 cd 当前cd 是否为二段
	for _, v in ipairs(skillVar) do
		inst["skill_" .. v] = net_float(inst.GUID, "skill." .. v, "skill_" .. v .. "_dirty")
	end
	inst["skill_" .. "level"] = net_ushortint(inst.GUID, "skill.level", "skill_level_dirty")
	inst.skill_state = net_bool(inst.GUID, "skill.state", "skill_state_dirty")

	inst.entity:SetPristine()

	--Common interface

	--- 客户端注册事件监听，响应变量变化
	if not TheWorld.ismastersim then
		--Client interface
		-- 服务器初始化时直接attach了，不需要classified主动attach
		inst.OnEntityReplicated = OnEntityReplicated

		--Delay net listeners until after initial values are deserialized
		inst:DoStaticTaskInTime(0, RegisterNetListeners)

		return inst
	end

	return inst
end

return Prefab("keqing_classified", fn)
