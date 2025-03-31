TimeEvent(7 * FRAMES, function(inst)
    if inst.sg.statemem.ismoose then
        if inst.sg.statemem.ismoosesmash then
            inst:PushMooseSmashShake()
            inst.sg:RemoveStateTag("nointerrupt")

            local x, y, z = inst.Transform:GetWorldPosition()
            local rot = inst.Transform:GetRotation()

            --V2C: first frame is blank, so no need to worry about forcing instant facing update
            local fx = SpawnPrefab("weremoose_smash_fx")
            fx.Transform:SetPosition(x, 0, z)
            fx.Transform:SetRotation(rot)
            fx._owner:set(inst)

            inst:ClearBufferedAction()
            inst.components.combat.ignorehitrange = true
            inst.components.combat:SetDefaultDamage(TUNING.SKILLS.WOODIE.MOOSE_SMASH_DAMAGE)
            local dist = 1
            local radius = 2
            rot = rot * DEGREES
            x = x + dist * math.cos(rot)
            z = z - dist * math.sin(rot)
            for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + 3, MOOSE_AOE_MUST_TAGS, MOOSE_AOE_CANT_TAGS)) do
                if v ~= inst and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
                    local range = radius + v:GetPhysicsRadius(0)
                    local dsq = v:GetDistanceSqToPoint(x, y, z)
                    if dsq < range * range and
                        (	v == inst.sg.statemem.attacktarget or --would mean we force attacked if needed
                            not inst:TargetForceAttackOnly(v)
                        ) and
                        inst.components.combat:CanTarget(v) and
                        not inst.components.combat:IsAlly(v)
                    then
                        if v.components.planarentity ~= nil then
                            inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WOODIE.MOOSE_SMASH_PLANAR_DAMAGE, "weremoose_smash")
                        end
                        inst.components.combat:DoAttack(v)
                        inst.components.planardamage:RemoveBonus(inst, "weremoose_smash")
                    end
                end
            end
            inst.components.combat:SetDefaultDamage(TUNING.WEREMOOSE_DAMAGE)
            inst.components.combat.ignorehitrange = false
        else
            inst:PerformBufferedAction()
        end
        inst.sg:RemoveStateTag("abouttoattack")
    end
end)