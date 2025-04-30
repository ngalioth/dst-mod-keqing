AddStategraphState(
	"wilson",
	State({
		name = "keqing_burst",
		tags = { "busy", "pausepredict", "nomorph", "nodangle" },
		onenter = function(inst)
			-- 进入无敌状态
			inst:AddTag("noattack")
			inst.components.health:SetInvincible(true)
			-- inst.components.burst:SetSkillCd()
			-- 全屏的滤镜或者是气场特效tbd
			local x, y, z = inst.Transform:GetWorldPosition()
			inst.components.burst:DoSkill("skill")
			inst._burst_task = inst:DoPeriodicTask(0.2, function()
				-- 8次斩击
				inst._burst_slash_count = (inst._burst_slash_count or 0) + 1
				if inst._burst_slash_count > 8 then
					if inst._burst_task ~= nil then
						inst._burst_task:Cancel()
						inst._burst_task = nil
						inst._burst_slash_count = 0
					end
					return
				end
				inst.components.burst:DoSkill("slash")
			end)
		end,
		-- 按照帧次数生成影子 按照出现顺序依次消失 最后一段影子消失时出现最后的斩击 影子不直接造成伤害，伤害就单独数帧造成吧
		timeline = { -- 消失前的蓄力 和一段斩击，暂时缺失
			TimeEvent(16 * FRAMES, function(inst)
				--- 这里处理角色消失
				-- 生成消失特效
				-- 展开场状特效 这里待做
				--- 播放消失特效
				local x, y, z = inst.Transform:GetWorldPosition()
				-- 隐藏角色模型
				inst:Hide()
				--- 隐藏影子
				inst.DynamicShadow:Enable(false)
				SpawnPrefab("keqing_burst_vanish_fx").Transform:SetPosition(x, y, z)
				--- kq_burst_begin 11帧
				SpawnPrefab("keqing_burst_1_fx").Transform:SetPosition(x, y, z)
			end), -- 28帧
			TimeEvent(28 * FRAMES, function(inst)
				--- 播放连斩的第一段特效，持续15帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_1_fx").Transform:SetPosition(x, y, z)
			end), -- 第43帧
			TimeEvent(43 * FRAMES, function(inst)
				-- 生成连斩的第二段特效，持续23帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_2_fx").Transform:SetPosition(x, y, z)
			end), --- 第66帧
			TimeEvent(66 * FRAMES, function(inst)
				-- 生成连斩特效3 持续15帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_3_fx").Transform:SetPosition(x, y, z)
			end), -- 第75帧 在连斩特效3结束前进入下一个sg，可打断的无敌状态，角色模型出现
			TimeEvent(75 * FRAMES, function(inst)
				inst.sg:GoToState("keqing_burst_pst")
			end),
		},
	})
)
-- 角色模型出现 不动继续无敌，等若干帧过后解除无敌。移动也解除无敌 播放end动画，最后一斩击
-- 该状态可打断
AddStategraphState(
	"wilson",
	State({
		name = "keqing_burst_pst",
		tags = { "pausepredict", "nomorph", "nodangle" },
		onenter = function(inst)
			-- 角色模型出现
			inst:Show()
			--影子
			inst.DynamicShadow:Enable(true)
		end,
		timeline = {
			TimeEvent(1 * FRAMES, function(inst)
				-- 延迟生成最后一次斩击和伤害
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_end_fx").Transform:SetPosition(x, y, z)
				inst.components.burst:DoSkill("last")

				-- 取消滤镜
			end),
		},
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		onexit = function(inst)
			inst:RemoveTag("noattack")
			inst.components.health:SetInvincible(false)
		end,
	})
)
-- SGwilson_client只是为了延迟补偿做的，更多时候其实根本接收不到事件
--- 绝大部分时候都只是为了响应一些action的，事件类型几乎没有 过后sprint可以做一下
AddStategraphState(
	"wilson_client",
	State({
		name = "keqing_burst",
		tags = { "busy", "pausepredict", "nomorph", "nodangle" },
		onenter = function(inst)
			-- 进入无敌状态
			-- inst:AddTag("noattack")
			-- inst.components.health:SetInvincible(true)
			-- -- 技能进入cd
			-- inst.components.burst:SetSkillCd()
			-- 全屏的滤镜或者是气场特效tbd
		end,
		-- 按照帧次数生成影子 按照出现顺序依次消失 最后一段影子消失时出现最后的斩击 影子不直接造成伤害，伤害就单独数帧造成吧
		timeline = { -- 消失前的蓄力 和一段斩击，暂时缺失
			TimeEvent(16 * FRAMES, function(inst)
				--- 这里处理角色消失
				-- 生成消失特效
				-- 展开场状特效 这里待做
				--- 播放消失特效
				local x, y, z = inst.Transform:GetWorldPosition()
				-- 隐藏角色模型
				SpawnPrefab("keqing_burst_vanish_fx").Transform:SetPosition(x, y, z)
				--- kq_burst_begin 11帧
				SpawnPrefab("keqing_burst_1_fx").Transform:SetPosition(x, y, z)
			end), -- 28帧
			TimeEvent(28 * FRAMES, function(inst)
				--- 播放连斩的第一段特效，持续15帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_1_fx").Transform:SetPosition(x, y, z)
			end), -- 第43帧
			TimeEvent(43 * FRAMES, function(inst)
				-- 生成连斩的第二段特效，持续23帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_2_fx").Transform:SetPosition(x, y, z)
			end), --- 第66帧
			TimeEvent(66 * FRAMES, function(inst)
				-- 生成连斩特效3 持续15帧
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_3_fx").Transform:SetPosition(x, y, z)
			end), -- 第75帧 在连斩特效3结束前进入下一个sg，可打断的无敌状态，角色模型出现
			TimeEvent(75 * FRAMES, function(inst)
				inst.sg:GoToState("keqing_burst_pst")
			end),
		},
	})
)
-- 角色模型出现 不动继续无敌，等若干帧过后解除无敌。移动也解除无敌 播放end动画，最后一斩击
-- 该状态可打断
AddStategraphState(
	"wilson_client",
	State({
		name = "keqing_burst_pst",
		tags = { "pausepredict", "nomorph", "nodangle" },
		onenter = function(inst)
			-- inst:Show()
			-- inst.DynamicShadow:Enable(true)
		end,
		timeline = {
			TimeEvent(1 * FRAMES, function(inst)
				-- 延迟生成最后一次斩击和伤害
				local x, y, z = inst.Transform:GetWorldPosition()
				SpawnPrefab("keqing_burst_end_fx").Transform:SetPosition(x, y, z)
				-- 取消滤镜
			end),
		},
		events = {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		onexit = function(inst)
			-- inst:RemoveTag("noattack")
			-- inst.components.health:SetInvincible(false)
		end,
	})
)

AddStategraphEvent(
	"wilson_client",
	EventHandler("do_burst", function(inst)
		inst.sg:GoToState("keqing_burst")
	end)
)
AddStategraphEvent(
	"wilson",
	EventHandler("do_burst", function(inst)
		inst.sg:GoToState("keqing_burst")
	end)
)
