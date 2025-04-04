local MakePlayerCharacter = require "prefabs/player_common"

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {}

-- 初始物品
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KEQING

local exclude_tags = {"INLIMBO", "companion", "wall", "abigail", "player", "chester"}

-- 当人物复活的时候
local function onbecamehuman(inst)
	-- 设置人物的移速（1表示1倍于wilson）
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "keqing_speed_mod", 1)
	--（也可以用以前的那种
	--inst.components.locomotor.walkspeed = 4
	--inst.components.locomotor.runspeed = 6）
end
--当人物死亡的时候
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
local function ongetitem(inst , data)
    if data.item and data.item.prefab == 'cursed_monkey_token' then
        inst.components.cursable:RemoveCurse('MONKEY', 20)
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

-- 释放元素战技
local function ElementalSkill(inst, x, y, z)
    if inst.components.timer:TimerExists("SKILL") and inst.skillcnt == 0 then return end
    if inst.components.rider and inst.components.rider:IsRiding() then return end -- 不在骑行状态
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
            local ents = TheSim:FindEntities(x, y, z, 2, {"_combat"}, exclude_tags)
            for i, ent in ipairs(ents) do
                if ent.components.combat then
                    inst:PushEvent("onareaattackother", { target = ent, weapon = item, stimuli = "electro" })
                    inst.components.combat:DoAttack(ent, item, nil, "electro", 1.07)
                end
            end
        elseif inst.skillcnt == 2 then
            inst.skillcnt = 0
            --第二次使用，传送至目标位置
            if inst.Physics then
                inst.Physics:Teleport(inst.pos.x , inst.pos.y , inst.pos.z)
            else
                inst.components.SetPosition(inst.pos.x , inst.pos.y , inst.pos.z)
            end
            inst.components.timer:StopTimer("LX")
            inst.lx:Remove()
            local fx = SpawnPrefab("kq_skill_fx")
            fx.Transform:SetPosition(inst.pos.x , inst.pos.y , inst.pos.z)
            fryfish(inst, 4)
            local x0, y0, z0 = inst.Transform:GetWorldPosition()
            -- 通过 TheSim:FindEntities() 函数查找周围的实体
            local ents = TheSim:FindEntities(x0, y0, z0, 4, {"_combat"}, exclude_tags)
            for i, ent in ipairs(ents) do
                if ent.components.combat then
                    inst:PushEvent("onareaattackother", { target = ent, weapon = item, stimuli = "electro" })
                    inst.components.combat:DoAttack(ent, item, nil, "electro", 3.57)
                end
            end
            inst.components.EleEnergy:DoDelta(9)
        end
	end
end

--元素爆发
local function ElementalBurst(inst)
    if inst.components.timer:TimerExists("BURST") then return end
	if inst ~= nil and inst:IsValid() and inst.components.health and not inst.components.health:IsDead() then  -- 存在，没寄
		if not inst.sg:HasStateTag("busy") and not (inst.components.rider ~= nil and inst.components.rider:IsRiding()) then -- 没其他动作，没骑牛
			if inst.components.EleEnergy and inst.components.EleEnergy.current >= 40 then
				if inst.kq_tjxytask == nil then
					if inst.components.talker then
						if math.random() <= 0.5 then
							inst.components.talker:Say("剑光如我，斩尽芜杂！")
						else
							inst.components.talker:Say("剑出，影随！")
						end
					end
					--开大期间无敌
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
						local ents = TheSim:FindEntities(x, y, z, radius, {"_combat"}, exclude_tags)
						for i, ent in ipairs(ents) do
							if ent ~= nil and ent:IsValid() and ent.components.health and not ent.components.health:IsDead() then
								--print("准备攻击了")
								inst.components.combat:DoAttack(ent, weapon, nil, "electro", mult)
								--print("让我康康！现在是第"..inst.tjxy_count.."段")
							end
						end
						fryfish(inst, 10)
					end)
				end
			end
		end
	end
end

--[[
local tbl = --10个
{
    1.87, 0.51, 0.51, 0.51, 0.51, 0.51, 0.51, 0.51, 0.51, 4.01,
}
local function Slash10(inst)
    local count = 0
    local item = inst.components.inventory.equipslots[EQUIPSLOTS.HANDS] -- 获取角色手持物
    inst._keqing_slash10 = inst:DoPeriodicTask(0.13, function ()
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 16, {"_combat"}, exclude_tags)
        for i, ent in ipairs(ents) do
            if ent.components.combat then
                inst:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = "electro" })
                --第一次伤害
                inst.components.combat:DoAttack(ent, item, nil, "electro", tbl[count])
            end
        end
        count = count + 1
        fryfish(inst, 10)
    end,0.1)
    inst:DoTaskInTime(1.3, function ()
        if inst._keqing_slash10 ~= nil then
            inst._keqing_slash10:Cancel()
            inst._keqing_slash10 = nil
        end
    end)
    inst:DoTaskInTime(1.9, function ()
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 16, {"_combat"}, exclude_tags)
        for i, ent in ipairs(ents) do
            if ent.components.combat then
                inst:PushEvent("onareaattackother", { target = ent, weapon = inst, stimuli = "electro" })
                --第一次伤害
                inst.components.combat:DoAttack(ent, item, nil, "electro", 4.01)
            end
        end
    end)
    inst:DoTaskInTime(2.2, function ()
        --解除无敌
        inst:RemoveTag("alwaysblock")
        inst:RemoveTag("noattack")
        inst.components.health:SetInvincible(false)
    end)
end

--元素爆发
local function ElementalBurst(inst)
    if inst.components.timer:TimerExists("BURST") then return end
    if inst.components.rider and inst.components.rider:IsRiding() then return end
    if not inst:HasTag("playerghost") and inst:HasTag("keqing") and inst.components.EleEnergy and inst.components.EleEnergy.current == 40 then
        if inst.components.talker then
            if math.random() <= 0.5 then
                inst.components.talker:Say("剑光如我，斩尽芜杂！")
            else
                inst.components.talker:Say("剑出，影随！")
            end
        end
        --开大期间无敌
        inst:AddTag("alwaysblock")
        inst:AddTag("noattack")
		inst.components.health:SetInvincible(true)
        inst.components.EleEnergy:DoDelta(-40)
        inst.components.timer:StartTimer("BURST", inst.burstcd)
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("lightning").Transform:SetPosition(x, y, z)
        SpawnPrefab("kq_burst_fx").Transform:SetPosition(x, y, z)
        Slash10(inst)
	end
end
]]

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

--添加RPC组件
AddModRPCHandler('keqing', 'skill', ElementalSkill)
AddModRPCHandler("keqing", "burst", ElementalBurst)

--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "keqing.tex" )
	inst:AddTag("keqing")
    inst:AddTag("electro")
    inst:AddTag("sword_class")
    inst:AddTag("genshin_character")
    inst:AddTag("bookbuilder") -- 可以做书？
    inst:AddTag("reader") -- 可以读书
    inst:AddTag("stronggrip") -- 武器工具不脱手
    inst:AddTag("kqhairpin_user")

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
    -- 双爆组件
    inst:AddComponent("kq_crit")
    inst.components.kq_crit:SetCrit(0.05) -- 暴击率
    inst.components.kq_crit:SetCritdmg(0.884) -- 暴击伤害
    inst:AddComponent("keqing_aoe_dmg")
    inst:AddComponent("elemental_burst")
    -- 按键组件
    inst:AddComponent("key")
    --元素战技组件
	inst.components.key:Press(_G[TUNING.KEQING_SKILL_KEY], "skill")
    --元素爆发组件
	inst.components.key:Press(_G[TUNING.KEQING_BURST_KEY], "burst")
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "wendy"
	-- 三维
	inst.components.health:SetMaxHealth(TUNING.KEQING_HEALTH)
	inst.components.hunger:SetMax(TUNING.KEQING_HUNGER)
	inst.components.sanity:SetMax(TUNING.KEQING_SANITY)
	-- 伤害系数
    inst.components.combat.damagemultiplier = 1
	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
    --闲置动作
	inst.customidleanim = "idle_wendy"
    --最喜欢食物
	inst.components.foodaffinity:AddPrefabAffinity("goldenshrimp", TUNING.AFFINITY_15_CALORIES_SMALL)--small是2.2，huge是1.2，klei真有你的

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

    inst:DoTaskInTime(2, function () -- 拖尾
        inst.kq_tailing = SpawnPrefab("kq_tailing_fx")
        if inst.kq_tailing ~= nil then
            inst.kq_tailing_offset = -105
            inst.kq_tailing.entity:AddFollower()
            inst.kq_tailing.entity:SetParent(inst.entity)
            inst.kq_tailing.Follower:FollowSymbol(inst.GUID, "swap_body", 0, inst.kq_tailing_offset or 0, 0)
        end
    end)

    inst:ListenForEvent("itemget", ongetitem)

    inst:DoPeriodicTask(0.1, update)

	inst.OnLoad = onload
    inst.OnNewSpawn = onload
end

--十分感谢风铃大佬提供的API
local function MakeSkin(name, data)
    local d = {}
    d.skin_tags = {"BASE" ,"keqing", "CHARACTER"}
    d.skins = {normal_skin = name, ghost_skin = 'ghost_keqing_build'}
    d.checkfn = nil
    d.checkclientfn = nil
    for k, v in pairs(data) do
        d[k] = v
    end
    SoraAPI.MakeCharacterSkin('keqing', name, d)
end

MakeSkin(
    'keqing_none',
    {
        name = STRINGS.SKIN_NAMES.keqing,
        type = 'base',
        des = STRINGS.CHARACTER_DESCRIPTIONS.keqing,
        quotes = STRINGS.CHARACTER_QUOTES.keqing,
        build_name_override = 'keqing',
        rarity = "Character", --角色，"HeirloomDistinguished" -- 祖传杰出，"Spiffy" -- 炫酷，"Event"--活动（限时使用）
        skins = {normal_skin = 'keqing', ghost_skin = 'ghost_keqing_build'},
        assets =
        {
            Asset("ANIM", "anim/keqing.zip" ),
            Asset("ANIM", "anim/ghost_keqing_build.zip" ),
        }
    }
)

MakeSkin(
    'keqing_eryuan',
    {
        name = STRINGS.SKIN_NAMES.keqing_eryuan,
        des = STRINGS.SKIN_DESCRIPTIONS.keqing_eryuan,
        quotes = STRINGS.SKIN_QUOTES.keqing_eryuan,
        build_name_override = 'keqing_eryuan',
        rarity = "Loyal", -- 忠诚
        rarity_modifier = 'CharacterModifier', --"Woven" -- 织造, "Inspierd" -- 启发
        skip_item_gen = true,
        skip_giftable_gen = true,
        assets =
        {
            Asset("ANIM", "anim/keqing_eryuan.zip"),
            Asset("ANIM", "anim/ghost_keqing_build.zip"),
        }
    }
)

MakeSkin(
    'keqing_nostalgia',
    {
        name = STRINGS.SKIN_NAMES.keqing_nostalgia,
        des = STRINGS.SKIN_DESCRIPTIONS.keqing_nostalgia,
        quotes = STRINGS.SKIN_QUOTES.keqing_nostalgia,
        build_name_override = 'keqing_nostalgia',
        rarity = "Timeless", -- 永恒
        rarity_modifier = "CharacterModifier",
        skip_item_gen = true,
        skip_giftable_gen = true,
        assets =
        {
            Asset("ANIM", "anim/keqing_nostalgia.zip"),
            Asset("ANIM", "anim/ghost_keqing_build.zip"),
        }
    }
)

MakeSkin(
    'keqing_gotomoon',
    {
        name = STRINGS.SKIN_NAMES.keqing_gotomoon,
        des = STRINGS.SKIN_DESCRIPTIONS.keqing_gotomoon,
        quotes = STRINGS.SKIN_QUOTES.keqing_gotomoon,
        build_name_override = 'keqing_gotomoon',
        rarity = "Elegant", -- 优雅, "HeirloomElegant" -- 祖传优雅，
        --raritycorlor = {0, 1, 0, 1};
        rarity_modifier = 'CharacterModifier',
        skip_item_gen = true,
        skip_giftable_gen = true,
        assets =
        {
            Asset( "ANIM", "anim/keqing_gotomoon.zip" ),
            Asset( "ANIM", "anim/ghost_keqing_build.zip" ),
        }
    }
)

MakeSkin(
    'keqing_telepole',
    {
        name = STRINGS.SKIN_NAMES.keqing_telepole,
        des = STRINGS.SKIN_DESCRIPTIONS.keqing_telepole,
        quotes = STRINGS.SKIN_QUOTES.keqing_telepole,
        build_name_override = 'keqing_telepole',
        rarity = "瓦尔普吉斯之夜", -- 自定义稀有度
        raritycorlor = {1, 1, 0, 1};
        rarity_modifier = 'CharacterModifier',
        skip_item_gen = true,
        skip_giftable_gen = true,
        assets =
        {
            Asset( "ANIM", "anim/keqing_telepole.zip" ),
            Asset( "ANIM", "anim/ghost_keqing_build.zip" ),
        }
    }
)

return MakePlayerCharacter("keqing", prefabs, assets, common_postinit, master_postinit, start_inv)