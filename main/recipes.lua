--非常非常感谢“能力勋章”的作者整理的这一份新版制作栏的详细内容
--[[
{
	name,--配方名，一般情况下和需要合成的道具同名
	ingredients,--配方
	tab,--合成栏(已废弃)
	level,--解锁科技
	placer,--建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
	min_spacing,--最小间距，不填默认为3.2
	nounlock,--不解锁配方，只能在满足科技条件的情况下制作(分类默认都算专属科技站,不需要额外添加了)
	numtogive,--一次性制作的数量，不填默认为1
	builder_tag,--制作者需要拥有的标签
	atlas,--需要用到的图集文件(.xml)，不填默认用images/name.xml
	image,--物品贴图(.tex)，不填默认用name.tex
	testfn,--尝试放下物品时的函数，可用于判断坐标点是否符合预期
	product,--实际合成道具，不填默认取name
	build_mode,--建造模式,水上还是陆地(默认为陆地BUILDMODE.LAND,水上为BUILDMODE.WATER)
	build_distance,--建造距离(玩家距离建造点的距离)
	filters,--制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	
	--扩展字段
	placer,--建筑类科技放置时显示的贴图、占位等
	filter,--制作栏分类
	description,--覆盖原来的配方描述
	canbuild,--制作物品是否满足条件的回调函数,支持参数(recipe, self.inst, pt, rotation),return 结果,原因
	sg_state,--自定义制作物品的动作(比如吹气球就可以调用吹的动作)
	no_deconstruction,--填true则不可分解(也可以用function)
	require_special_event,--特殊活动(比如冬季盛宴限定之类的)
	dropitem,--制作后直接掉落物品
	actionstr,--把"制作"改成其他的文字
	manufactured,--填true则表示是用制作站制作的，而不是用builder组件来制作(比如万圣节的药水台就是用这个)
}
--]]

local recipes = {
	-- 石珀
	{
		name = "kq_amber", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("rocks", 2), -- 石头
			Ingredient("nitre", 2), -- 硝石
		},
		level = TECH.NONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_amber.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_amber.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 仙家琥珀
	{
		name = "kq_lightamber", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("goldnugget", 4), -- 金块
			Ingredient("rocks", 4), -- 石头
			Ingredient("kq_amber", 2, "images/inventoryimages/kq_amber.xml"), -- 石珀
		},
		level = TECH.NONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_lightamber.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_lightamber.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "STRUCTURES", "CHARACTER", "LIGHT" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
		placer = "kq_lightamber_placer", -- placer,--建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
	},
	-- 营养袋
	{
		name = "kq_foodbag", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("rope", 1), -- 绳子
			Ingredient("transistor", 2), -- 电子元件
			Ingredient("waxpaper", 1), -- 蜡纸
		},
		level = TECH.SCIENCE_TWO, --二本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_foodbag.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_foodbag.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 背包
	{
		name = "kq_backpack", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("rope", 2),
			Ingredient("sewing_kit", 1),
			Ingredient("beefalowool", 8),
			Ingredient("coontail", 1),
		},
		level = TECH.SCIENCE_TWO, --二本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_backpack.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_backpack.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CLOTHING", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 便携锅
	{
		name = "kq_liyuepot_item", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("charcoal", 6),
			Ingredient("cutstone", 2),
			Ingredient("goldnugget", 2),
		},
		level = TECH.SCIENCE_TWO, --二本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_liyuepot_item.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_liyuepot_item.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "COOKING", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 发簪
	{
		name = "kq_hairpins", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("wagpunk_bits", 1),
			Ingredient("petals", 6),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_hairpins.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_hairpins.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CLOTHING", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 流明石触媒
	{
		name = "kq_lightstone", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("lightbulb", 6),
			Ingredient("cutstone", 2),
			Ingredient("wagpunk_bits", 1),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_lightstone.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_lightstone.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "LIGHT", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 磐岩结绿
	{
		name = "greensword", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("greengem", 2),
			Ingredient("thulecite", 6),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/greensword.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "greensword.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "WAR", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 捕风瓶
	{
		name = "kq_windbottle", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("messagebottleempty", 1),
			Ingredient("fireflies", 1),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_windbottle.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_windbottle.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 红羽团扇
	{
		name = "kq_redfun", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("malbatross_feather", 6),
			Ingredient("feather_robin", 2),
			Ingredient("log", 1),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_redfun.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_redfun.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 奇特的羽毛
	{
		name = "kq_elecfur", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("goose_feather", 6),
			Ingredient("tentaclespots", 1),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_elecfur.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_elecfur.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 放热瓶
	{
		name = "kq_hotbottle", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("messagebottleempty", 1),
			Ingredient("heatrock", 1),
		},
		level = TECH.SCIENCE_TWO, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_hotbottle.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_hotbottle.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 留念镜
	{
		name = "kq_foxmirror", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("moonglass", 6),
			Ingredient("purplegem", 2),
			Ingredient("moonbutterfly", 2),
		},
		level = TECH.CELESTIAL_THREE, --天体科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_foxmirror.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_foxmirror.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 初生白枝
	{
		name = "kq_whitetwigs", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("seeds", 20),
			Ingredient("treegrowthsolution", 2),
			Ingredient("twigs", 1),
		},
		level = TECH.MAGIC_THREE, --四本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_whitetwigs.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_whitetwigs.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 镇石断片
	{
		name = "kq_splitrock", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("kq_amber", 6, "images/inventoryimages/kq_amber.xml"),
			Ingredient("townportaltalisman", 6),
			Ingredient("marble", 6),
		},
		level = TECH.MAGIC_THREE, --四本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_splitrock.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_splitrock.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 戴丧面具
	{
		name = "kq_ladytomb", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("nightmarefuel", 5),
			Ingredient("ruinshat", 1),
		},
		level = TECH.ANCIENT_FOUR, --完整远古塔
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_ladytomb.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_ladytomb.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 深邃之血
	{
		name = "kq_dragonblood", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("moonglass_charged", 6),
			Ingredient("nightmarefuel", 6),
			Ingredient("purplegem", 2),
		},
		level = TECH.MAGIC_THREE, --四本
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_dragonblood.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_dragonblood.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 永恒领域游览指南
	{
		name = "kq_42", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("deerclops_eyeball", 1),
		},
		level = TECH.BOOKCRAFT_ONE, --书架
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_42.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_42.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 日月前事
	{
		name = "kq_eclipse", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("yellowgem", 2),
			Ingredient("moonrocknugget", 5),
		},
		level = TECH.BOOKCRAFT_ONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_eclipse.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_eclipse.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 菲谢尔皇女夜谭
	{
		name = "kq_fischer", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("shadowheart", 1),
		},
		level = TECH.BOOKCRAFT_ONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_fischer.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_fischer.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 野猪公主·卷一
	{
		name = "kq_peppapig", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("nightmarefuel", 6),
			Ingredient("purplegem", 2),
		},
		level = TECH.BOOKCRAFT_ONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_peppapig.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_peppapig.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 丘丘语诗歌选
	{
		name = "kq_qqlangpoem", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("meat_dried", 2),
			Ingredient("kelp_dried", 2),
		},
		level = TECH.BOOKCRAFT_ONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_qqlangpoem.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_qqlangpoem.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 丘丘语速查手册
	{
		name = "kq_qqlookup", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("papyrus", 2),
			Ingredient("pigskin", 5),
			Ingredient("manrabbit_tail", 5),
		},
		level = TECH.BOOKCRAFT_ONE, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_qqlookup.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_qqlookup.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
	-- 电线杆
	{
		name = "kq_telepole", -- 配方名，一般情况下和需要合成的道具同名
		-- 配方
		ingredients = {
			Ingredient("dreadstone", 6),
			Ingredient("trinket_6", 6),
			Ingredient("houndstooth", 2),
		},
		level = TECH.ANCIENT_FOUR, --解锁科技
		builder_tag = "keqing",
		atlas = "images/inventoryimages/kq_telepole.xml", -- 需要用到的图集文件(.xml)，不填默认用images/name.xml
		image = "kq_telepole.tex", --物品贴图(.tex)，不填默认用name.tex
		filters = { "WAR", "CHARACTER" }, -- 制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	},
}

for k, data in pairs(recipes) do
	AddRecipe2(data.name, data.ingredients, data.level, {
		min_spacing = data.min_spacing,
		nounlock = data.nounlock,
		numtogive = data.numtogive,
		builder_tag = data.builder_tag,
		atlas = data.atlas,
		image = data.image,
		testfn = data.testfn,
		product = data.product,
		build_mode = data.build_mode,
		build_distance = data.build_distance,
		placer = data.placer,
		filter = data.filter,
		description = data.description,
		canbuild = data.canbuild,
		sg_state = data.sg_state,
		no_deconstruction = data.no_deconstruction,
		require_special_event = data.require_special_event,
		dropitem = data.dropitem,
		actionstr = data.actionstr,
		manufactured = data.manufactured,
	}, data.filters)
end

--添加可烹饪材料
AddIngredientValues({ "petals" }, { -- 花瓣
	description = 1, -- description：1单位装饰
})
AddIngredientValues({ "ash" }, { -- 灰
	inedible = 1, -- inedible：1单位不可食用度
})

AddIngredientValues({ "kq_shrimp" }, { -- 虾
	meat = 0.5, -- meat：0.5单位肉度
	fish = 0.5, -- fish: 0.5单位鱼度
})

AddIngredientValues({ "kq_cookedshrimp" }, { -- 熟虾
	meat = 0.5, -- meat：0.5单位肉度
	fish = 0.5, -- fish: 0.5单位鱼度
})

AddIngredientValues({ "kq_deadshrimp" }, { -- 虾仁
	meat = 0.5, -- meat：0.5单位肉度
	fish = 0.5, -- fish: 0.5单位鱼度
})

AddIngredientValues({ "kq_cookeddeadshrimp" }, { -- 熟虾仁
	meat = 0.5, -- meat：0.5单位肉度
	fish = 0.5, -- fish: 0.5单位鱼度
})

local kq_goldenshrimp = {
	test = function(cooker, names, tags)
		return (
			names.wobster_sheller_land
			or names.kq_shrimp
			or names.kq_cookedshrimp
			or names.kq_deadshrimp
			or names.kq_cookeddeadshrimp
		)
			and names.potato
			and names.petals
			and not tags.egg -- and not tags.inedible
	end,
	name = "kq_goldenshrimp", -- 料理名
	weight = 100, -- 食谱权重
	priority = 30, -- 食谱优先级
	foodtype = GLOBAL.FOODTYPE.MEAT, --料理的食物类型，比如这里定义的是肉类
	health = 40, --吃后回血值
	hunger = 75, --吃后回饥饿值
	sanity = 20, --吃后回精神值
	perishtime = TUNING.PERISH_SUPERSLOW, --腐烂时间
	cooktime = 0.25, --烹饪时间
	potlevel = "high",
	cookbook_tex = "kq_goldenshrimp.tex", -- 在游戏内食谱书里的mod食物那一栏里显示的图标，tex在atlas的xml里定义了，所以这里只写文件名即可
	cookbook_atlas = "images/food/kq_goldenshrimp.xml",
	-- temperature = TUNING.HOT_FOOD_BONUS_TEMP, --某些食物吃了之后有温度变化，则是在这地方定义的
	-- temperatureduration = TUNING.FOOD_TEMP_BRIEF,
	floater = { "med", nil, 0.55 },
	cookbook_category = "cookpot",
}

--AddCookerRecipe("cookpot", kq_goldenshrimp) -- 将食谱添加进普通锅
AddCookerRecipe("portablecookpot", kq_goldenshrimp) -- 将食谱添加进便携锅
AddCookerRecipe("kq_liyuepot", kq_goldenshrimp) -- 将食谱添加进mod锅

local kq_pocketcake = {
	test = function(cooker, names, tags)
		return tags.meat and names.tomato and tags.dairy and not tags.inedible
	end,
	name = "kq_pocketcake", -- 料理名
	weight = 100, -- 食谱权重
	priority = 30, -- 食谱优先级
	foodtype = GLOBAL.FOODTYPE.MEAT, --料理的食物类型，比如这里定义的是肉类
	health = 20, --吃后回血值
	hunger = 120, --吃后回饥饿值
	sanity = 5, --吃后回精神值
	perishtime = TUNING.PERISH_SUPERSLOW, --腐烂时间
	cooktime = 0.5, --烹饪时间
	potlevel = "high",
	cookbook_tex = "kq_pocketcake.tex", -- 在游戏内食谱书里的mod食物那一栏里显示的图标，tex在atlas的xml里定义了，所以这里只写文件名即可
	cookbook_atlas = "images/food/kq_pocketcake.xml",
	-- temperature = TUNING.HOT_FOOD_BONUS_TEMP, --某些食物吃了之后有温度变化，则是在这地方定义的
	-- temperatureduration = TUNING.FOOD_TEMP_BRIEF,
	floater = { "med", nil, 0.55 },
	cookbook_category = "cookpot",
}

--AddCookerRecipe("cookpot", pocketcake) -- 将食谱添加进普通锅
AddCookerRecipe("portablecookpot", kq_pocketcake) -- 将食谱添加进便携锅
AddCookerRecipe("kq_liyuepot", kq_pocketcake) -- 将食谱添加进mod锅

local kq_grilledfish = {
	test = function(cooker, names, tags)
		return tags.fish and names.twigs and tags.veggie
	end,
	name = "kq_grilledfish", -- 料理名
	weight = 100, -- 食谱权重
	priority = 30, -- 食谱优先级
	foodtype = GLOBAL.FOODTYPE.MEAT, --料理的食物类型，比如这里定义的是肉类
	health = 20, --吃后回血值
	hunger = 50, --吃后回饥饿值
	sanity = 5, --吃后回精神值
	perishtime = TUNING.PERISH_SUPERSLOW, --腐烂时间
	cooktime = 0.5, --烹饪时间
	potlevel = "high",
	cookbook_tex = "kq_grilledfish.tex", -- 在游戏内食谱书里的mod食物那一栏里显示的图标，tex在atlas的xml里定义了，所以这里只写文件名即可
	cookbook_atlas = "images/food/kq_grilledfish.xml",
	-- temperature = TUNING.HOT_FOOD_BONUS_TEMP, --某些食物吃了之后有温度变化，则是在这地方定义的
	-- temperatureduration = TUNING.FOOD_TEMP_BRIEF,
	floater = { "med", nil, 0.55 },
	cookbook_category = "cookpot",
}

--AddCookerRecipe("cookpot", kq_grilledfish) -- 将食谱添加进普通锅
AddCookerRecipe("portablecookpot", kq_grilledfish) -- 将食谱添加进便携锅
AddCookerRecipe("kq_liyuepot", kq_grilledfish) -- 将食谱添加进mod锅

local kq_friedegg = {
	test = function(cooker, names, tags)
		return tags.egg and not tags.meat and not tags.veggie
	end,
	name = "kq_friedegg", -- 料理名
	weight = 100, -- 食谱权重
	priority = 30, -- 食谱优先级
	foodtype = GLOBAL.FOODTYPE.GOODIES, --料理的食物类型，比如这里定义的是好东西类
	health = 20, --吃后回血值
	hunger = 40, --吃后回饥饿值
	sanity = 20, --吃后回精神值
	perishtime = TUNING.PERISH_SUPERSLOW, --腐烂时间
	cooktime = 0.5, --烹饪时间
	potlevel = "high",
	cookbook_tex = "kq_friedegg.tex", -- 在游戏内食谱书里的mod食物那一栏里显示的图标，tex在atlas的xml里定义了，所以这里只写文件名即可
	cookbook_atlas = "images/food/kq_friedegg.xml",
	-- temperature = TUNING.HOT_FOOD_BONUS_TEMP, --某些食物吃了之后有温度变化，则是在这地方定义的
	-- temperatureduration = TUNING.FOOD_TEMP_BRIEF,
	floater = { "med", nil, 0.55 },
	cookbook_category = "cookpot",
}

--AddCookerRecipe("cookpot", kq_friedegg) -- 将食谱添加进普通锅
AddCookerRecipe("portablecookpot", kq_friedegg) -- 将食谱添加进便携锅
AddCookerRecipe("liyuepot", kq_friedegg) -- 将食谱添加进mod锅
