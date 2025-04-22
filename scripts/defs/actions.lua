--[[
-----actions-----自定义动作
{
	id,--动作ID
	str,--动作显示名字
	fn,--动作执行函数
	actiondata,--其他动作数据，诸如strfn、mindistance等，可参考actions.lua
	state,--关联SGstate,可以是字符串或者函数
	canqueuer,--兼容排队论 allclick为默认，rightclick为右键动作
}
-----component_actions-----动作和组件绑定
{
	type,--动作类型
		*SCENE--点击物品栏物品或世界上的物品时执行,比如采集
		*USEITEM--拿起某物品放到另一个物品上点击后执行，比如添加燃料
		*POINT--装备某手持武器或鼠标拎起某一物品时对地面执行，比如植物人种田
		*EQUIPPED--装备某物品时激活，比如装备火把点火
		*INVENTORY--物品栏右键执行，比如吃东西
	component,--绑定的组件
	tests,--尝试显示动作，可写多个绑定在同一个组件上的动作及尝试函数
}
-----old_actions-----修改老动作
{
	switch,--开关，用于确定是否需要修改
	id,--动作ID
	actiondata,--需要修改的动作数据，诸如strfn、fn等，可不写
	state,--关联SGstate,可以是字符串或者函数
}
--]]
-- 获取堆叠数量
local function GetStackSize(item)
	return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end
-- 移除预制物(预制物,数量)
local function removeItem(item, num)
	if item.components.stackable then
		item.components.stackable:Get(num):Remove()
	else
		item:Remove()
	end
end
local ITEMS = {
	kq_lightstone = "lightstone", -- 流明石触媒
	kq_elecfur = "waterelec", -- 奇特的羽毛
	kq_redfun = "acce", -- 红羽团扇
	kq_hotbottle = "cold", -- 放热瓶
	kq_coldbottle = "hot", -- 制冷瓶
	kq_hotcore = "colddam", -- 常燃火种
	kq_coldcore = "hotdam", -- 极寒之核
	kq_foxmirror = "realdmg", -- 留念镜
	kq_splitrock = "nohit", -- 镇石断片
	kq_windbottle = "nodust", -- 捕风瓶
	kq_ladytomb = "ghostfriendly", -- 戴丧面具
	kq_whitetwigs = "talk", -- 初生白枝
	kq_dragonblood = "percdmg", -- 深邃之血
}
-- 自定义动作
local actions = { ----------------------------INVENTORY道具栏右键----------------------------
	-- {
	-- 	id = "READCLOSEDBOOK", --阅读无字天书
	-- 	str = STRINGS.MEDAL_NEWACTION.READCLOSEDBOOK,
	-- 	fn = function(act)
	-- 		if act.doer ~= nil and act.doer:HasTag("medal_canstudy") and act.invobject ~= nil and act.invobject.prefab=="closed_book" then
	-- 			local c_book = act.invobject.components.book
	-- 			if c_book ~= nil then
	-- 				local read_sanity = c_book.read_sanity or 0
	-- 				local sanity_current = act.doer.components.sanity and act.doer.components.sanity.current or 0
	-- 				--没有san值？那你别学了
	-- 				if sanity_current < read_sanity then
	-- 					return false,"NOSANITY"
	-- 				end
	-- 				-- local success, reason = c_book:OnRead(act.doer)
	-- 				local success, reason = c_book:Interact(c_book.onread, act.doer)
	-- 				if success and act.doer.components.sanity then
	-- 					local ismount = act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding()
	-- 					local fx = ismount and c_book.fxmount or c_book.fx
	-- 					if fx ~= nil then
	-- 						fx = SpawnPrefab(fx)
	-- 						if ismount then
	-- 							--In case we did not specify fxmount, convert fx to SixFaced
	-- 							fx.Transform:SetSixFaced()
	-- 						end
	-- 						fx.Transform:SetPosition(act.doer.Transform:GetWorldPosition())
	-- 						fx.Transform:SetRotation(act.doer.Transform:GetRotation())
	-- 					end
	-- 					act.doer.components.sanity:DoDelta(read_sanity)
	-- 				end
	-- 				if success then
	-- 					local medal = act.doer.components.inventory:EquipMedalWithName("wisdom_test_certificate")--获取玩家的蒙昧勋章
	-- 					if medal and medal.components.finiteuses then
	-- 						local istemporary = act.doer.components.reader==nil or IsMedalTempCom(act.doer,"reader") or act.doer.temporary_nomalreader--是否是临时读者(小鱼妹也是临时读者)
	-- 						local consume = (istemporary and 1 or 2)*TUNING_MEDAL.WISDOM_TEST.READ_CONSUME
	-- 						medal.components.finiteuses:Use(consume)
	-- 						if not RewardToiler(act.doer,0.1) then--天道酬勤
	-- 							SpawnMedalTips(act.doer,consume,5)--弹幕提示
	-- 						end
	-- 					end
	-- 				end
	-- 				return success, reason
	-- 			end
	-- 		end
	-- 	end,
	-- 	state = "book",
	-- 	actiondata = {
	-- 		priority=7,
	-- 		mount_valid=true,
	-- 	},
	-- },
	----------------------------USEITEM拿起某物品放到另一个物品上点击后执行----------------------------
	{
		id = "KQUPGRADEHAIRPINS", -- 发簪升级用
		str = "升级发簪",
		fn = function(act)
			-- tbd 修改发簪属性
			-- if
			if act.doer ~= nil and act.invobject ~= nil and ITEMS[act.invobject.prefab] ~= nil then
				local flag = ITEMS[act.invobject.prefab]
				local target = act.target
				target[flag] = math.min(target[flag] + 1, 1)
				removeItem(act.invobject)
			end
			return true
		end,
		state = "give",
		actiondata = {
			priority = 10, -- 99999,
			mount_valid = true,
		},
	},
	{
		id = "UPGRADEABLE_KEQING",
		str = "通用升级",
		fn = function(act)
			if act.doer ~= nil and act.invobject ~= nil and act.target ~= nil and act.target.components.refinement then
				local item = act.invobject
				local target = act.target
				if target.components.refinement:DoRefine(item, act.doer) then
					removeItem(item)
					return true
				end
			end
			return false
		end,
		state = "give",
		actiondata = {
			stroverridefn = function(act)
				local invobj = act.invobject
				local target = act.target
				if invobj ~= nil and target ~= nil then
					if target.components.refinement and invobj.prefab == target.prefab then
						return "精练"
					end
					if target.prefab == "keqing_pjc" or "kq_hairpins" then
						return "升级"
					end
				end
			end,
			priority = 10, -- 99999,
			mount_valid = true,
		},
	},

	----------------------------SCENE点击物品----------------------------
	-- {
	-- 	id = "TOUCHMEDALTOWER", --摸塔
	-- 	str = STRINGS.MEDAL_NEWACTION.TOUCHMEDALTOWER,
	-- 	fn = function(act)
	-- 		if act.doer ~= nil and act.doer:HasTag("space_medal") and act.target ~= nil and act.target:HasTag("medal_delivery") then
	-- 			local medal = act.doer.components.inventory and act.doer.components.inventory:EquipMedalWithTag("candelivery")
	-- 			if medal then
	-- 				if act.target.components.medal_delivery then
	-- 					act.target.components.medal_delivery:OpenScreen(act.doer)
	-- 				end
	-- 			else
	-- 				MedalSay(act.doer,STRINGS.DELIVERYSPEECH.FALSEMEDAL)
	-- 			end
	-- 			return true
	-- 		end
	-- 	end,
	-- 	state = "give",
	-- 	actiondata = {
	-- 		distance=2.1,
	-- 		priority=10,--99999,
	-- 	},
	-- },
	----------------------------EQUIPPED装备物品激活----------------------------
	-- {
	-- 	id = "MEDALPOURWATER", --加水
	-- 	str = STRINGS.MEDAL_NEWACTION.MEDALPOURWATER,
	-- 	fn = function(act)
	-- 		if act.doer ~= nil and act.invobject ~= nil and act.invobject:HasTag("wateringcan") and act.target ~= nil and act.target:HasTag("canpourwater") then
	-- 			if act.invobject.components.finiteuses ~= nil then
	-- 				if act.invobject.components.finiteuses:GetUses() <= 0 then
	-- 					return false, (act.invobject:HasTag("wateringcan") and "OUT_OF_WATER" or nil)
	-- 				else
	-- 					act.invobject.components.finiteuses:Use()
	-- 				end
	-- 			end
	-- 			if act.target.prefab=="medal_waterpump" then
	-- 				if not act.target.candrewwater then
	-- 					act.target.candrewwater=true
	-- 					act.target.AnimState:PlayAnimation("use_pst")
	-- 				end
	-- 			elseif act.target.prefab=="medal_ice_machine" then
	-- 				if act.target.AddWater then
	-- 					act.target:AddWater(2)
	-- 				end
	-- 			end
	-- 			return true
	-- 		end
	-- 	end,
	-- 	state = "pour",
	-- 	actiondata = {
	-- 		distance=1.5,
	-- 	},
	-- }
}

-- 动作与组件绑定
local component_actions = {
	{
		type = "USEITEM",
		component = "inventoryitem",
		tests = {
			{
				action = "KQUPGRADEHAIRPINS", -- 发簪升级
				testfn = function(inst, doer, target, actions, right)
					local flag = ITEMS[inst.prefab]
					if flag ~= nil and target.prefab == "kq_hairpins" and target[flag] ~= 1 then
						return true
					end
					return false
				end,
			},
			{
				action = "UPGRADEABLE_KEQING", -- 通用升级
				testfn = function(inst, doer, target, actions, right)
					if target ~= nil and target.components.refinement then
						return target.components.refinement:CanAcceptItem(inst.prefab)
					end
					return false
				end,
			},
		},
	},
}

return {
	actions = actions,
	component_actions = component_actions,
	old_actions = nil,
}
