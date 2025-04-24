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
		print("enable sprint succeed")
		if inst._parent then
			inst._parent.components.keqing:EnableSprint(true)
		end
	end,
	[COMMANDS.DISABLESPRINT] = function(inst)
		print("disable succeed")
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
	print("Unsupported Keqing command:", cmd)
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
	print("Unsupported Keqing command:", cmd)
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
	inst:ListenForEvent("sprint_dirty", function(inst)
		print("sprint dirty value is " .. tostring(inst.sprint:value()))
	end)
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
	-- 是否开启冲刺
	inst.sprint = net_bool(inst.GUID, "keqing_classified.sprint", "sprint_dirty")

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
