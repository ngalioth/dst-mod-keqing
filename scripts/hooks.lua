------------------ [[ 主机 ]] ---------------------------
AddStategraphPostInit("wilson", function(sg)
    -- [[ 鸣进入动作 ]]
    if sg.states["combat_superjump"] ~= nil then
        local old_combat_superjump_ontimeout = sg.states["combat_superjump"].ontimeout
        sg.states["combat_superjump"].ontimeout = function(inst, ...)
            --- 开始的判断条件，感觉还需要加点
            if inst.prefab == "keqing" and ins.elemental_burst ~= nil then
                local num = 8 -- 斩击次数 其中前五次有分身，后面隐藏
                local pos = inst:GetPosition() -- 获取当前角色位置 可能有问题，这是自动补的！！！！！！！！
                local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                local radius = 6 -- 斩击半径
                --- here 做第一次斩击 应当在落地的同时
                -- tbd
                --- 这里开始进行后续
                inst.keqing_elemental_burst_slash_task = inst:DoPeriodicTask(0.2, function(inst, ...)
                    inst.keqing_elemental_burst_slash_count = (inst.keqing_elemental_burst_slash_count or 0) + 1
                    if inst.keqing_elemental_burst_slash_count > num then
                        inst.keqing_elemental_burst_slash_task:Cancel()
                        inst.keqing_elemental_burst_slash_task = nil
                        inst.keqing_elemental_burst_slash_count = nil
                        -- [[ 原函数 ]]
                        if old_combat_superjump_ontimeout ~= nil then
                            old_combat_superjump_ontimeout(inst, ...)
                        end
                    else
                        local roa = math.random() * 2 * PI
                        local offset = Vector3(math.cos(roa) * radius, 0, math.sin(roa) * radius)

                        local keqing_shadow = SpawnPrefab("keqing_shadow")
                        keqing_shadow.acheron_thunder_sword_shadow = true -- 标记影子，让他生成特效
                        keqing_shadow:SetThunderAnim(inst.AnimState:GetBuild()) -- 设置角色动画
                        keqing_shadow.Transform:SetPosition(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z)
                        keqing_shadow:ForceFacePoint(pos:Get())
                        keqing_shadow:TryAttack(pos.x, pos.y, pos.z, inst, weapon, nil,
                            TUNING.ACHERON_THUNDER_SWORDS_SHADOWLUNGE_MULT, radius)
                    end
                end)
            end
        end
    end
end)
