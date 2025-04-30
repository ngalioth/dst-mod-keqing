local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "player", "chester" }
local function fryfish(inst, radius)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ent0 = TheSim:FindEntities(x, y, z, radius)
	for i, ent in ipairs(ent0) do
		if ent:HasTag("fish") or ent:HasTag("fishmeat") or ent.prefab == "fish_cooked" then
			if not ent:HasTag("INLIMBO") then
				local fishpos = ent:GetPosition()
				SpawnPrefab("kq_specialfish").Transform:SetPosition(fishpos:Get())
				ent:Remove()
			end
		end
	end
end
-- 释放元素战技
local function ElementalSkill(inst, x, y, z)
	if inst.components.timer:TimerExists("SKILL") and inst.skillcnt == 0 then
		return
	end
	if inst.components.rider and inst.components.rider:IsRiding() then
		return
	end -- 不在骑行状态
	if not inst:HasTag("playerghost") and inst:HasTag("keqing") then -- 人物还在，且为keqing
		local item = inst.components.inventory.equipslots[EQUIPSLOTS.HANDS]
		if item and item.components.weapon == nil then
			item = nil
		end
		inst.skillcnt = inst.skillcnt + 1 -- 计数，判断第几次使用该技能
		if inst.skillcnt == 1 then
			if inst.components.talker then
				if math.random() <= 0.5 then
					inst.components.talker:Say("可别眨眼！")
				else
					inst.components.talker:Say("迅影如剑！")
				end
			end
			inst.pos = inst:GetPosition() -- 第一次使用，记录鼠标位置
			inst.pos.x, inst.pos.y, inst.pos.z = x, y, z
			inst.components.timer:StartTimer("SKILL", inst.skillcd)
			inst.lx = SpawnPrefab("leixie")
			inst.lx.Transform:SetPosition(x, y, z)
			inst.components.timer:StartTimer("LX", 5)
			fryfish(inst.lx, 2)
			local ents = TheSim:FindEntities(x, y, z, 2, { "_combat" }, exclude_tags)
			for i, ent in ipairs(ents) do
				if ent.components.combat then
					inst:PushEvent("onareaattackother", {
						target = ent,
						weapon = item,
						stimuli = "electro",
					})
					inst.components.combat:DoAttack(ent, item, nil, "electro", 1.07)
				end
			end
		elseif inst.skillcnt == 2 then
			inst.skillcnt = 0
			-- 第二次使用，传送至目标位置
			if inst.Physics then
				inst.Physics:Teleport(inst.pos.x, inst.pos.y, inst.pos.z)
			else
				inst.components.SetPosition(inst.pos.x, inst.pos.y, inst.pos.z)
			end
			inst.components.timer:StopTimer("LX")
			inst.lx:Remove()
			local fx = SpawnPrefab("kq_skill_fx")
			fx.Transform:SetPosition(inst.pos.x, inst.pos.y, inst.pos.z)
			fryfish(inst, 4)
			local x0, y0, z0 = inst.Transform:GetWorldPosition()
			-- 通过 TheSim:FindEntities() 函数查找周围的实体
			local ents = TheSim:FindEntities(x0, y0, z0, 4, { "_combat" }, exclude_tags)
			for i, ent in ipairs(ents) do
				if ent.components.combat then
					inst:PushEvent("onareaattackother", {
						target = ent,
						weapon = item,
						stimuli = "electro",
					})
					inst.components.combat:DoAttack(ent, item, nil, "electro", 3.57)
				end
			end
		end
	end
end

-- -- 添加RPC组件
-- AddModRPCHandler("keqing", "skill", ElementalSkill)
-- AddModRPCHandler("keqing", "burst", ElementalBurst)
local ServerRPCs = {
	["burst"] = function(player)
		if player.components.burst then
			player.components.burst:TryDoSkill()
		end
	end,
	-- pos is Vector3 for the mouse position
	["skill"] = function(player, x, y, z)
		if player.components.skill and x and y and z then
			local pos = Vector3(x, y, z)
			player.components.skill:TryDoSkill(pos)
		end
	end,
}
--- 由于有状态变化，本地执行之前要先判断能不能，类似于动作触发器要在本地执行
--- 确定可以执行要推送相对应的事件，主机同样要推送事件

for k, v in pairs(ServerRPCs) do
	AddModRPCHandler("keqing", k, v)
end
-- 添加RPC组件
-- AddModRPCHandler("keqing", "skill", ElementalSkill)
-- AddModRPCHandler("keqing", "burst", ElementalBurst)
