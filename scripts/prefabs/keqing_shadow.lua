--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- local acheron_coordinate_util = require("util/acheron_coordinate_util")
-- local CalcTargetCoordByMouse = acheron_coordinate_util.CalcTargetCoordByMouse

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- 获取人物面前的坐标
local function CalcCoordFront(inst, dist, front1_behind0)
	if inst ~= nil and dist ~= nil and front1_behind0 ~= nil then
		local angle = inst.Transform:GetRotation()
		local pos_x, _, pos_z = inst.Transform:GetWorldPosition()
		local radian_angle = (angle - 90) * DEGREES

		local final_x = pos_x + dist * math.sin(radian_angle) * (-1) ^ front1_behind0
		local final_z = pos_z + dist * math.cos(radian_angle) * (-1) ^ front1_behind0

		return final_x, 0, final_z
	end
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- 获取某物体方向固定距离坐标
local function CalcTargetCoordByMouse(inst, mx, my, mz, dist)
	local cx, cy, cz = inst.Transform:GetWorldPosition()
	local dx = mx - cx
	local dz = mz - cz

	local x, y, z
	local distance = math.sqrt(dx * dx + dz * dz)
	if distance > 0 then
		local unit_dx = dx / distance
		local unit_dz = dz / distance

		x = cx + unit_dx * dist
		y = cy
		z = cz + unit_dz * dist

		return x, y, z
	else -- = 0
		return CalcCoordFront(inst, dist, 1)
	end
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
local assets = {}
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
local prefabs = {}
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
local function SetThunderAnim(inst, build)
	inst.AnimState:SetBuild(build)
	inst.AnimState:OverrideSymbol("swap_object", "swap_greensword", "swap_greensword")
end
--------------------------------------------------------------------------------------------------------
local function RotateFX(fx, inst, tx, ty, tz)
	fx.Transform:SetPosition(tx, ty, tz)
	fx.Transform:SetRotation(inst.Transform:GetRotation())
end

local random_fx = { "shadowstrike_slash_fx", "shadowstrike_slash2_fx" }
local function DoAttack(inst, tx, ty, tz, owner, weapon, specialmult, overridemult, overrideradius)
	-- 特效
	RotateFX(SpawnPrefab(random_fx[math.random(1, 2)]), inst, tx, ty, tz)
	-- 出伤
	if
		inst ~= nil
		and inst:IsValid()
		and owner ~= nil
		and owner:IsValid()
		and owner.components.health ~= nil
		and not owner.components.health:IsDead()
		and owner.components.combat ~= nil
	then
		local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "player", "structure" }
		local ents =
			TheSim:FindEntities(tx, ty, tz, overrideradius or TUNING.ACHERON_SKILL_RANGE, { "_combat" }, exclude_tags)
		local combat = owner.components.combat
		for _, ent in ipairs(ents) do
			if ent ~= nil and ent:IsValid() and ent ~= inst and combat:IsValidTarget(ent) then
				owner:PushEvent("onareaattackother", {
					target = ent,
					weapon = weapon,
				})
				local mult = overridemult or TUNING.ACHERON_SKILL_SHADOWMULT
				mult = specialmult ~= nil and mult * specialmult or mult
				-- combat:DoAttack(ent, weapon, nil, nil, mult)
				local dmg, spdmg = owner.components.combat:CalcDamage(ent, weapon, mult)
				owner:PushEvent("onattackother", {
					target = ent,
					weapon = weapon,
				})
				ent.components.combat:GetAttacked(owner, dmg, weapon, spdmg)
				if ent.sg:HasState("hit") then
					ent.sg:GoToState("hit")
				end
			end
		end
	end
	inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
end

local function TryAttack(inst, tx, ty, tz, owner, weapon, specialmult, overridemult)
	SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())

	inst.AnimState:PlayAnimation("lunge_pst")

	inst:ListenForEvent("animover", function(inst)
		inst:DoTaskInTime(2 * FRAMES, function(inst)
			inst:Remove()
		end)
	end)

	inst:DoTaskInTime(1 * FRAMES, function(inst)
		-- 调整终点的位置坐标，使得在怪物身后一点
		local current_dist = math.sqrt(inst:GetDistanceSqToPoint(tx, ty, tz))
		local dist = current_dist + TUNING.ACHERON_SKILL_MOREDIST
		local x, y, z = CalcTargetCoordByMouse(inst, tx, ty, tz, dist)
		-- 鸣 召唤的影子给特效
		if inst.acheron_thunder_sword_shadow then
			local fx = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
			fx.Transform:SetPosition(x, 0, z)
			fx.Transform:SetRotation(inst:GetRotation())
		end
		inst.Physics:Teleport(x, 0, z)
	end)

	inst:DoTaskInTime(4 * FRAMES, function(inst)
		-- 实际攻击效果
		DoAttack(inst, tx, ty, tz, owner, weapon, specialmult, overridemult)
	end)

	inst:DoTaskInTime(9 * FRAMES, function(inst)
		inst.Physics:ClearMotorVelOverride()
	end)
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced(inst)

	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(5)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:SetCapsule(0.5, 1)

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("acheron")
	inst.AnimState:SetMultColour(1, 1, 1, 0.75)
	inst.AnimState:OverrideSymbol("swap_object", "acheron_sword_hide", "swap_wuqi")

	inst:AddTag("scarytoprey")
	inst:AddTag("NOBLOCK")
	inst:AddTag("acheron_shadow")

	inst.SetThunderAnim = SetThunderAnim

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst.TryAttack = TryAttack

	return inst
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
return Prefab("acheron_shadow", fn, assets, prefabs)
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
