local MakePlayerCharacter = require("prefabs/player_common")

local assets = { Asset("SCRIPT", "scripts/prefabs/player_common.lua") }

local prefabs = {
	"keqing_classified",
}

-- 初始物品
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KEQING

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

	inst.skillcdleft = net_float(inst.GUID, "inst.skillcdleft")
	inst.ChangeSkillIcon1 = net_bool(inst.GUID, "ChangeSkillIcon1")

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
	inst:AddComponent("skill")
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

	inst:ListenForEvent("itemget", ongetitem)

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
