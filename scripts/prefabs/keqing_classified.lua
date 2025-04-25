--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------
local COMMAND_NAMES = {
	"ENABLESPRINT",
	"DISABLESPRINT",
}
local COMMANDS = table.invert(COMMAND_NAMES)

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------
local CmdFns_Server = {
	[COMMANDS.ENABLESPRINT] = function(inst)
		modprint("enable sprint succeed")
		if inst._parent then
			inst._parent.components.keqing:EnableSprint(true)
		end
	end,
	[COMMANDS.DISABLESPRINT] = function(inst)
		modprint("disable succeed")
		if inst._parent then
			inst._parent.components.keqing:EnableSprint(false)
		end
	end,
}

local function ExecuteCommand_Server(inst, cmd)
	local fn = CmdFns_Server[cmd]
	if fn then
		return fn(inst)
	end
	modprint("Unsupported Keqing command:", cmd)
	return false
end

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------
-- 客户端不进行其他操作，仅发送RPC
local function BasicCommand_Client(inst, cmd)
	-- SendRPCToServer(RPC.WobyCommand, cmd)
	SendModRPCToServer(MOD_RPC["keqing"]["command"], cmd)
	return true
end
local CmdFns_Client = {
	[COMMANDS.ENABLESPRINT] = BasicCommand_Client,
	[COMMANDS.DISABLESPRINT] = BasicCommand_Client,
}
-- 大部分其实也只是rpc封装，具体执行的东西在ClientCommands定义里面
--- rpc根据cmd在Commands_Server里面找到对应的函数执行
local function ExecuteCommand_Client(inst, cmd)
	-- if not IgnoreBusy_Client[cmd] and IsBusy_Client(inst) then
	-- 	return false
	-- end
	local fn = CmdFns_Client[cmd]
	-- dumptable(CmdFns_Client)
	if fn then
		return fn(inst, cmd)
	end
	modprint("Unsupported Keqing command:", cmd)
	return false
end

--Triggered on clients immediately after initial deserialization of tags from construction
local function OnRemoveEntity(inst)
	if inst._parent ~= nil then
		inst._parent.keqing_classified = nil
	end
end
local function OnEntityReplicated(inst)
	inst._parent = inst.entity:GetParent()
	if inst._parent == nil then
		-- moderror("Unable to initialize classified data for keqing", level)
		--- 实际上客户端由于classifedTarget的设置，只能由classified主动调用parent的attach
	else
		--- 由于需要绑定过多组件，延迟0s保证生效
		inst:DoStaticTaskInTime(0, function(inst)
			-- 这里分别调用对应组件的AttachClassified
			for i, v in ipairs({ "keqing", "burst" }) do
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
local function on_burst_dirty(inst)
	if inst._parent ~= nil then
		local data = {
			level = inst.burst_level:value(),
			cd = inst.burst_cd:value(),
			maxcd = inst.burst_maxcd:value(),
			energy = inst.burst_energy:value(),
			maxenergy = inst.burst_maxenergy:value(),
		}
		inst._parent:PushEvent("burst_d", data)
	end
end

--------------------------------------------------------------------------
local function OnInitialDirtyStates(inst) end

local function RegisterNetListeners_mastersim(inst) end

local function RegisterNetListeners_local(inst)
	inst:ListenForEvent("burst_level_dirty", on_burst_dirty)
	inst:ListenForEvent("burst_cd_dirty", on_burst_dirty)
	inst:ListenForEvent("burst_maxcd_dirty", on_burst_dirty)
	inst:ListenForEvent("burst_energy_dirty", on_burst_dirty)
	inst:ListenForEvent("burst_maxenergy_dirty", on_burst_dirty)
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
	-- OnSayDirty(inst)
	inst:ListenForEvent("sprint_dirty", function(inst)
		modprint("sprint dirty value is " .. tostring(inst.sprint:value()))
	end)
end

--------------------------------------------------------------------------

local burstVar = {
	"cd",
	"maxcd",
	"energy",
	"maxenergy",
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
	inst.sprint = net_bool(inst.GUID, "keqing_classified.sprint", "sprint_dirty")
	-- 是否开启语音
	inst.audio = net_bool(inst.GUID, "keqing_classified.audio", "audio_dirty")

	-- 元素爆发 等级 cd 当前cd 最大能量 当前能量
	for _, v in ipairs(burstVar) do
		inst["burst_" .. v] = net_float(inst.GUID, "burst." .. v, "burst_" .. v .. "_dirty")
	end
	inst.burst_level = net_ushortint(inst.GUID, "burst.level", "burst_level_dirty")

	-- 元素战技 cd 当前cd 是否为二段
	inst.skill_cd = net_float(inst.GUID, "keqing_classified.skill_cd", "skill_cd_dirty")
	inst.skill_current_cd = net_float(inst.GUID, "keqing_classified.skill_current_cd", "skill_current_cd_dirty")
	inst.skill_state = net_bool(inst.GUID, "keqing_classified.skill_state", "skill_state_dirty")

	inst.entity:SetPristine()

	--Common interface

	--- 客户端注册事件监听，响应变量变化
	if not TheWorld.ismastersim then
		--Client interface
		-- 服务器初始化时直接attach了，不需要classified主动attach
		inst.OnEntityReplicated = OnEntityReplicated

		--Delay net listeners until after initial values are deserialized
		inst:DoStaticTaskInTime(0, RegisterNetListeners)
		inst.ExecuteCommand = ExecuteCommand_Client

		return inst
	end

	--Server interface
	inst.ExecuteCommand = ExecuteCommand_Server

	return inst
end

return Prefab("keqing_classified", fn)
