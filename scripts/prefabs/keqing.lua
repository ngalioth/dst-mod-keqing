local MakePlayerCharacter = require("prefabs/player_common")

local assets = { Asset("SCRIPT", "scripts/prefabs/player_common.lua") }

local prefabs = {
	"keqing_classified",
}

-- 初始物品
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KEQING

local exclude_tags = { "INLIMBO", "companion", "wall", "abigail", "player", "chester" }

local EMPTY_TABLE = {}
-- 当人物复活的时候
local function onbecamehuman(inst)
	-- 设置人物的移速（1表示1倍于wilson）
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "keqing_speed_mod", 1)
	-- （也可以用以前的那种
	-- inst.components.locomotor.walkspeed = 4
	-- inst.components.locomotor.runspeed = 6）
end
-- 当人物死亡的时候
local function onbecameghost(inst)
	-- 变成鬼魂的时候移除速度修正
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "keqing_speed_mod")
end

-- 重载游戏或者生成一个玩家的时候
local function onload(inst)
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	inst:ListenForEvent("ms_becameghost", onbecameghost)
	if inst:HasTag("playerghost") then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end
end

-- 防止变猴诅咒
local function ongetitem(inst, data)
	if data.item and data.item.prefab == "cursed_monkey_token" then
		inst.components.cursable:RemoveCurse("MONKEY", 20)
	end
end

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
--------------------------------------------------------------------------

--pos: double click coords; nil when double tapping direction instead of mouse
--dir: WASD/analog dir; nil if neutral (NOTE: this may be in a different direction than pos!)
--target: double click mouseover target; nil when tapping direction instead of mouse
--remote: only pos2 is sent to server, similar to actions that are aimed toward reticule pos、
local function GetDoubleClickActions(inst, pos, dir, target)
	-- love from woby
	--- 过后设置一个变量控制开关吧
	-- if true then
	-- 	local pos2
	-- 	if dir then
	-- 		pos2 = inst:GetPosition()
	-- 		pos2.x = pos2.x + dir.x * 10
	-- 		pos2.y = 0
	-- 		pos2.z = pos2.z + dir.z * 10
	-- 	elseif target then
	-- 		pos2 = target:GetPosition()
	-- 		pos2.y = 0
	-- 	end
	-- 	return { ACTIONS.DASH }, pos2
	-- end
	return EMPTY_TABLE
end
-- onsetowner 似乎是实例化完成过后？反正这些操作必须在该事件后进行
local function OnSetOwner(inst)
	if inst.components.playeractionpicker then
		-- inst.components.playeractionpicker.doubleclickactionsfn = GetDoubleClickActions
		-- inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
	end
	-- 其实倒也不是classified没实例化，是inst没有，如果是nil直接加就行了，例如lucy
	if inst.keqing_classified then
		inst.keqing_classified.Network:SetClassifiedTarget(inst)
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
			inst.components.EleEnergy:DoDelta(9)
		end
	end
end

-- 元素爆发
local function ElementalBurst(inst)
	if inst.components.timer:TimerExists("BURST") then
		return
	end
	if inst ~= nil and inst:IsValid() and inst.components.health and not inst.components.health:IsDead() then -- 存在，没寄
		if
			not inst.sg:HasStateTag("busy") and not (inst.components.rider ~= nil and inst.components.rider:IsRiding())
		then -- 没其他动作，没骑牛
			if inst.components.EleEnergy and inst.components.EleEnergy.current >= 40 then
				if inst.kq_tjxytask == nil then
					if inst.components.talker then
						if math.random() <= 0.5 then
							inst.components.talker:Say("剑光如我，斩尽芜杂！")
						else
							inst.components.talker:Say("剑出，影随！")
						end
					end
					-- 开大期间无敌
					inst:AddTag("noattack")
					inst.components.health:SetInvincible(true)
					inst.components.EleEnergy:DoDelta(-40)
					inst.components.timer:StartTimer("BURST", 12)
					-- 生成特效
					local x, y, z = inst.Transform:GetWorldPosition()
					-- 通过 TheSim:FindEntities() 函数查找周围的实体
					SpawnPrefab("lightning").Transform:SetPosition(x, y, z)
					SpawnPrefab("kq_burst_fx").Transform:SetPosition(x, y, z)
					-- 连续造成十段伤害
					inst.kq_tjxytask = inst:DoPeriodicTask(0.2, function(inst)
						print("进来了")
						-- 记录攻击段数
						inst.tjxy_count = (inst.tjxy_count or 0) + 1
						-- 打完10段停下
						if inst.tjxy_count > 10 then
							if inst.kq_tjxytask ~= nil then
								inst.kq_tjxytask:Cancel()
								inst.kq_tjxytask = nil
								inst.tjxy_count = 0
							end
							inst:RemoveTag("noattack")
							inst.components.health:SetInvincible(false)
							-- 保险一下（
							return
						end
						-- 计算倍率
						local mult = 0.51
						if inst.tjxy_count == 1 then
							mult = 1.87
						elseif inst.tjxy_count == 10 then
							mult = 4.01
						else
							mult = 0.51
						end
						-- 搜索目标并给予伤害
						local radius = 10
						local weapon = inst.components.inventory.equipslots[EQUIPSLOTS.HANDS]
						local ents = TheSim:FindEntities(x, y, z, radius, { "_combat" }, exclude_tags)
						for i, ent in ipairs(ents) do
							if
								ent ~= nil
								and ent:IsValid()
								and ent.components.health
								and not ent.components.health:IsDead()
							then
								-- print("准备攻击了")
								inst.components.combat:DoAttack(ent, weapon, nil, "electro", mult)
								-- print("让我康康！现在是第"..inst.tjxy_count.."段")
							end
						end
						fryfish(inst, 10)
					end)
				end
			end
		end
	end
end

local function update(inst)
	inst.skillcdleft:set(inst.components.timer ~= nil and inst.components.timer:GetTimeLeft("SKILL") or 0)
	inst.burstcdleft:set(inst.components.timer ~= nil and inst.components.timer:GetTimeLeft("BURST") or 0)
	if not inst.components.timer:TimerExists("LX") and inst.lx ~= nil then
		inst.ChangeSkillIcon1:set(false)
		inst.lx:Remove()
		inst.skillcnt = 0
	end
	if inst.components.timer:TimerExists("LX") and inst.lx ~= nil then
		inst.ChangeSkillIcon1:set(true)
	end
end

AddModRPCHandler("keqing", "command", function(player, cmd)
	if not checkuint(cmd) then
		printinvalid("KeqingCommand", player)
		return
	end

	if player.keqing_classified then
		player.keqing_classified:ExecuteCommand(cmd)
	else
		moderror("Player cannot use Keqing commands")
	end
end)
-- 添加RPC组件
AddModRPCHandler("keqing", "skill", ElementalSkill)
AddModRPCHandler("keqing", "burst", ElementalBurst)
-- 这俩暴击独立计算了，需要额外处理，神经暴击机制
local function CustomCombatDamage(inst, target, weapon, multiplier, mount)
	if inst.components.stats_manager ~= nil then
		return inst.components.stats_manager:GetDamageBonus()
	end

	return 1
end
local function CustomSPCombatDamage(inst, target, weapon, multiplier, mount)
	if inst.components.stats_manager ~= nil then
		return inst.components.stats_manager:GetSpDamageBonus()
	end
	return 1
end

-- 这个函数将在服务器和客户端都会执行
-- 一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon("keqing.tex")
	inst:AddTag("keqing")
	inst:AddTag("electro")
	inst:AddTag("sword_class")
	inst:AddTag("genshin_character")
	--- 大概后续要移除，无条件作书显示不合适
	-- inst:AddTag("bookbuilder") -- 可以做书？
	inst:AddTag("reader") -- 可以读书
	--- 这个显然也不太合适
	-- inst:AddTag("stronggrip") -- 武器工具不脱手
	inst:AddTag("kqhairpin_user")
	--- 添加一些自定义动作 shift
	inst:ListenForEvent("setowner", OnSetOwner)

	inst.skillcd = 7.5
	inst.burstcd = 12
	inst.skillcdleft = net_float(inst.GUID, "inst.skillcdleft")
	inst.burstcdleft = net_float(inst.GUID, "inst.burstcdleft")
	inst.maxenergy = net_ushortint(inst.GUID, "maxenergy", "maxenergy_dirty")
	inst.currentenergy = net_ushortint(inst.GUID, "currentenergy", "currentenergy_dirty")
	inst.ChangeSkillIcon1 = net_bool(inst.GUID, "ChangeSkillIcon1")
	-- 添加元素能量组件
	inst:AddComponent("EleEnergy")
	inst.components.EleEnergy:SetMax(40)
	-- 按键组件
	inst:AddComponent("key")
	-- 元素战技组件
	inst.components.key:Press(_G[TUNING_KEQING.SKILL_KEY], "skill")
	-- 元素爆发组件
	inst.components.key:Press(_G[TUNING_KEQING.BURST_KEY], "burst")
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "wendy"
	-- 三维
	inst.components.health:SetMaxHealth(TUNING_KEQING.HEALTH)
	inst.components.hunger:SetMax(TUNING_KEQING.HUNGER)
	inst.components.sanity:SetMax(TUNING_KEQING.SANITY)
	-- 负责初始化classified，所以要早一点
	inst:AddComponent("keqing")
	-- 伤害系数
	inst.components.combat.damagemultiplier = 1
	--- 技能组件
	inst:AddComponent("keqing_aoe_dmg")
	inst:AddComponent("burst")
	--- 管理角色暴击和增伤
	inst:AddComponent("stats_manager")
	-- 自定义加成，算暴击和增伤
	inst.components.combat.customdamagemultfn = CustomCombatDamage
	inst.components.combat.customspdamagemultfn = CustomSPCombatDamage

	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	-- 闲置动作
	inst.customidleanim = "idle_wendy"
	-- 最喜欢食物
	inst.components.foodaffinity:AddPrefabAffinity("goldenshrimp", TUNING.AFFINITY_15_CALORIES_SMALL) -- small是2.2，huge是1.2，klei真有你的

	inst.skillcnt = 0
	inst.pos = nil
	inst.lx = nil

	inst:AddComponent("reader")

	if inst.components.workmultiplier == nil then
		inst:AddComponent("workmultiplier") -- 增加工作效率
	end

	inst.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, 1.5, inst) -- 砍树效率
	inst.components.workmultiplier:AddMultiplier(ACTIONS.MINE, 1.5, inst) -- 挖矿效率
	inst.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 1.5, inst) -- 锤子效率
	inst.components.workmultiplier:AddMultiplier(ACTIONS.DIG, 1.5, inst) -- 铲子效率

	-- if TUNING.KEQING_SHOWTAIL == "on" then

	-- end

	inst:ListenForEvent("itemget", ongetitem)

	inst:DoPeriodicTask(0.1, update)

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
end

-- 十分感谢风铃大佬提供的API
local function MakeSkin(name, data)
	local d = {}
	d.skin_tags = { "BASE", "keqing", "CHARACTER" }
	d.skins = {
		normal_skin = name,
		ghost_skin = "ghost_keqing_build",
	}
	d.checkfn = nil
	d.checkclientfn = nil
	for k, v in pairs(data) do
		d[k] = v
	end
	SoraAPI.MakeCharacterSkin("keqing", name, d)
end

MakeSkin("keqing_none", {
	name = STRINGS.SKIN_NAMES.keqing,
	type = "base",
	des = STRINGS.CHARACTER_DESCRIPTIONS.keqing,
	quotes = STRINGS.CHARACTER_QUOTES.keqing,
	build_name_override = "keqing",
	rarity = "Character", -- 角色，"HeirloomDistinguished" -- 祖传杰出，"Spiffy" -- 炫酷，"Event"--活动（限时使用）
	skins = {
		normal_skin = "keqing",
		ghost_skin = "ghost_keqing_build",
	},
	assets = { Asset("ANIM", "anim/keqing.zip"), Asset("ANIM", "anim/ghost_keqing_build.zip") },
})

MakeSkin("keqing_eryuan", {
	name = STRINGS.SKIN_NAMES.keqing_eryuan,
	des = STRINGS.SKIN_DESCRIPTIONS.keqing_eryuan,
	quotes = STRINGS.SKIN_QUOTES.keqing_eryuan,
	build_name_override = "keqing_eryuan",
	rarity = "Loyal", -- 忠诚
	rarity_modifier = "CharacterModifier", -- "Woven" -- 织造, "Inspierd" -- 启发
	skip_item_gen = true,
	skip_giftable_gen = true,
	assets = { Asset("ANIM", "anim/keqing_eryuan.zip"), Asset("ANIM", "anim/ghost_keqing_build.zip") },
})

MakeSkin("keqing_nostalgia", {
	name = STRINGS.SKIN_NAMES.keqing_nostalgia,
	des = STRINGS.SKIN_DESCRIPTIONS.keqing_nostalgia,
	quotes = STRINGS.SKIN_QUOTES.keqing_nostalgia,
	build_name_override = "keqing_nostalgia",
	rarity = "Timeless", -- 永恒
	rarity_modifier = "CharacterModifier",
	skip_item_gen = true,
	skip_giftable_gen = true,
	assets = { Asset("ANIM", "anim/keqing_nostalgia.zip"), Asset("ANIM", "anim/ghost_keqing_build.zip") },
})

MakeSkin("keqing_gotomoon", {
	name = STRINGS.SKIN_NAMES.keqing_gotomoon,
	des = STRINGS.SKIN_DESCRIPTIONS.keqing_gotomoon,
	quotes = STRINGS.SKIN_QUOTES.keqing_gotomoon,
	build_name_override = "keqing_gotomoon",
	rarity = "Elegant", -- 优雅, "HeirloomElegant" -- 祖传优雅，
	-- raritycorlor = {0, 1, 0, 1};
	rarity_modifier = "CharacterModifier",
	skip_item_gen = true,
	skip_giftable_gen = true,
	assets = { Asset("ANIM", "anim/keqing_gotomoon.zip"), Asset("ANIM", "anim/ghost_keqing_build.zip") },
})

MakeSkin("keqing_telepole", {
	name = STRINGS.SKIN_NAMES.keqing_telepole,
	des = STRINGS.SKIN_DESCRIPTIONS.keqing_telepole,
	quotes = STRINGS.SKIN_QUOTES.keqing_telepole,
	build_name_override = "keqing_telepole",
	rarity = "瓦尔普吉斯之夜", -- 自定义稀有度
	raritycorlor = { 1, 1, 0, 1 },
	rarity_modifier = "CharacterModifier",
	skip_item_gen = true,
	skip_giftable_gen = true,
	assets = { Asset("ANIM", "anim/keqing_telepole.zip"), Asset("ANIM", "anim/ghost_keqing_build.zip") },
})

return MakePlayerCharacter("keqing", prefabs, assets, common_postinit, master_postinit, start_inv)
