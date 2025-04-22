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
