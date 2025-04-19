local kq_ego_show = GLOBAL.State({
	name = "kq_ego_show",
	tags = { "doing", "busy", "canrotate", "nointerrupt", "nomorph", "nopredict" },
	onenter = function(inst, data)
		inst.components.locomotor:Stop()
		if inst.components.playercontroller ~= nil then
			inst.components.playercontroller:RemotePausePrediction()
		end
		if data and data.pos then
			local pos = data.pos:GetPosition()
			inst.angle = inst:GetAngleToPoint(pos.x, 0, pos.z)
			inst:ForceFacePoint(pos.x, 0, pos.z)
		end
		inst.components.locomotor:EnableGroundSpeedMultiplier(false)
		inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
		inst.AnimState:PushAnimation("wortox_portal_jumpin_lag", false)
		-- 冲刺速度
		inst.Physics:SetMotorVelOverride(30, 0, 0)
		-- 冲刺时长
		inst.sg:SetTimeout(0.3)
	end,
	ontimeout = function(inst)
		inst.sg:GoToState("idle")
	end,
	onexit = function(inst)
		inst.sg:GoToState("idle")
	end,
})

local kq_ego_erose = GLOBAL.State({
	name = "kq_ego_erose",
	tags = { "doing", "busy", "canrotate", "nointerrupt", "nomorph", "nopredict" },
	onenter = function(inst, data)
		inst.components.locomotor:Stop()
		if inst.components.playercontroller ~= nil then
			inst.components.playercontroller:RemotePausePrediction()
		end
		if data and data.pos then
			local pos = data.pos:GetPosition()
			inst.angle = inst:GetAngleToPoint(pos.x, 0, pos.z)
			inst:ForceFacePoint(pos.x, 0, pos.z)
		end
		inst.components.locomotor:EnableGroundSpeedMultiplier(false)
		inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
		inst.AnimState:PushAnimation("wortox_portal_jumpin_lag", false)
		-- 冲刺速度
		inst.Physics:SetMotorVelOverride(30, 0, 0)
		-- 冲刺时长
		inst.sg:SetTimeout(0.3)
	end,
	ontimeout = function(inst)
		inst.sg:GoToState("idle")
	end,
	onexit = function(inst)
		inst.sg:GoToState("idle")
	end,
})

AddStategraphState(
	"wilson",
	State({
		name = "kq_charge",
		tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },
		onenter = function(inst, data)
			inst.components.health:SetInvincible(true)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_leap_lag")
			if data ~= nil then
				inst:ForceFacePoint(data:Get())
			else
				inst:ForceFacePoint(inst:GetPosition():Get())
			end
			inst.Physics:SetMotorVelOverride(30, 0, 0)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst.sg.statemem.beginpos = inst:GetPosition()
			inst.sg.statemem.targetpos = data
			-- 冲刺时长
			inst.sg:SetTimeout(0.3)
		end,
		onupdate = function(inst)
			inst.Physics:SetMotorVelOverride(30, 0, 0)
		end,
		ontimeout = function(inst)
			inst.sg:GoToState("idle")
		end,
		onexit = function(inst)
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			inst.Physics:ClearMotorVelOverride()
			inst.components.locomotor:Stop()
			inst.components.health:SetInvincible(false)
		end,
	})
)

AddStategraphState(
	"wilson_client",
	State({
		name = "kq_charge",
		tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },
		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("atk_leap_lag")
			if data ~= nil then
				inst:ForceFacePoint(data:Get())
			else
				inst:ForceFacePoint(inst:GetPosition():Get())
			end
			inst.sg:SetTimeout(0.3)
		end,
		ontimeout = function(inst)
			inst.sg:GoToState("idle")
		end,
	})
)
