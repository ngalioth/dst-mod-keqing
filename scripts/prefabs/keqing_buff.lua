-------------------------------------------------------------------------
---------------------- Attach and dettach functions ---------------------
-------------------------------------------------------------------------
-- 这里留着做玉衡之贵的buff
local function aristocratic_dignity_attach(inst, target)
	-- if target.components.combat ~= nil then
	-- 	target.components.combat.externaldamagemultipliers:SetModifier(inst, 0.15)
	-- end
	if target.components.stats_manager ~= nil then
		target.components.stats_manager.bonus:SetModifier(inst, TUNING.BUFF_ATTACK_bonus)
	end
end

local function aristocratic_dignity_detach(inst, target)
	-- if target.components.combat ~= nil then
	--     target.components.combat.externaldamagemultipliers:RemoveModifier(inst)
	-- end
	if target.components.stats_manager ~= nil then
		target.components.stats_manager.bonus:RemoveModifier(inst)
	end
end

-------------------------------------------------------------------------
----------------------- Prefab building functions -----------------------
-------------------------------------------------------------------------

local function OnTimerDone(inst, data)
	if data.name == "buffover" then
		inst.components.debuff:Stop()
	end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
	local ATTACH_BUFF_DATA = {
		buff = "ANNOUNCE_ATTACH_BUFF_" .. string.upper(name),
		priority = priority,
	}
	local DETACH_BUFF_DATA = {
		buff = "ANNOUNCE_DETACH_BUFF_" .. string.upper(name),
		priority = priority,
	}

	local function OnAttached(inst, target)
		inst.entity:SetParent(target.entity)
		inst.Transform:SetPosition(0, 0, 0) -- in case of loading
		inst:ListenForEvent("death", function()
			inst.components.debuff:Stop()
		end, target)
		-- 不是食物buff不需要触发额外的事件
		-- target:PushEvent("foodbuffattached", ATTACH_BUFF_DATA)
		if onattachedfn ~= nil then
			onattachedfn(inst, target)
		end
	end

	local function OnExtended(inst, target)
		inst.components.timer:StopTimer("buffover")
		inst.components.timer:StartTimer("buffover", duration)

		-- target:PushEvent("foodbuffattached", ATTACH_BUFF_DATA)
		if onextendedfn ~= nil then
			onextendedfn(inst, target)
		end
	end

	local function OnDetached(inst, target)
		if ondetachedfn ~= nil then
			ondetachedfn(inst, target)
		end
		--- 类似的
		-- target:PushEvent("foodbuffdetached", DETACH_BUFF_DATA)
		inst:Remove()
	end

	local function fn()
		local inst = CreateEntity()

		if not TheWorld.ismastersim then
			-- Not meant for client!
			inst:DoTaskInTime(0, inst.Remove)
			return inst
		end

		inst.entity:AddTransform()

		--[[Non-networked entity]]
		-- inst.entity:SetCanSleep(false)
		inst.entity:Hide()
		inst.persists = false

		inst:AddTag("CLASSIFIED")

		inst:AddComponent("debuff")
		inst.components.debuff:SetAttachedFn(OnAttached)
		inst.components.debuff:SetDetachedFn(OnDetached)
		inst.components.debuff:SetExtendedFn(OnExtended)
		inst.components.debuff.keepondespawn = true

		inst:AddComponent("timer")
		inst.components.timer:StartTimer("buffover", duration)
		inst:ListenForEvent("timerdone", OnTimerDone)

		return inst
	end

	return Prefab("buff_" .. name, fn, nil, prefabs)
end

local ARISTOCRATIC_DIGNITY_DURATION = 8
return MakeBuff(
	"aristocratic_dignity",
	aristocratic_dignity_attach,
	nil,
	aristocratic_dignity_detach,
	ARISTOCRATIC_DIGNITY_DURATION,
	1
)
