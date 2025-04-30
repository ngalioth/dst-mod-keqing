local SKILL_MULT_DATA = {
	{ -- LV1
		thunder_wedge_damage = 50.0, -- 雷楔伤害
		slash_damage = 168, -- 斩击伤害
		thunderstorm_slash_damage = 84.0 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV2
		thunder_wedge_damage = 54.2, -- 雷楔伤害
		slash_damage = 181, -- 斩击伤害
		thunderstorm_slash_damage = 90.3 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV3
		thunder_wedge_damage = 58.0, -- 雷楔伤害
		slash_damage = 193, -- 斩击伤害
		thunderstorm_slash_damage = 96.6 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV4
		thunder_wedge_damage = 63.0, -- 雷楔伤害
		slash_damage = 210, -- 斩击伤害
		thunderstorm_slash_damage = 105 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV5
		thunder_wedge_damage = 66.8, -- 雷楔伤害
		slash_damage = 223, -- 斩击伤害
		thunderstorm_slash_damage = 111 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV6
		thunder_wedge_damage = 70.6, -- 雷楔伤害
		slash_damage = 235, -- 斩击伤害
		thunderstorm_slash_damage = 118 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV7
		thunder_wedge_damage = 75.6, -- 雷楔伤害
		slash_damage = 252, -- 斩击伤害
		thunderstorm_slash_damage = 126 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV8
		thunder_wedge_damage = 80.6, -- 雷楔伤害
		slash_damage = 269, -- 斩击伤害
		thunderstorm_slash_damage = 134 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV9
		thunder_wedge_damage = 86.0, -- 雷楔伤害
		slash_damage = 286, -- 斩击伤害
		thunderstorm_slash_damage = 143 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV10
		thunder_wedge_damage = 90.7, -- 雷楔伤害
		slash_damage = 302, -- 斩击伤害
		thunderstorm_slash_damage = 151 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV11
		thunder_wedge_damage = 95.8, -- 雷楔伤害
		slash_damage = 319, -- 斩击伤害
		thunderstorm_slash_damage = 160 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV12
		thunder_wedge_damage = 101.0, -- 雷楔伤害
		slash_damage = 336, -- 斩击伤害
		thunderstorm_slash_damage = 168 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV13
		thunder_wedge_damage = 107.0, -- 雷楔伤害
		slash_damage = 357, -- 斩击伤害
		thunderstorm_slash_damage = 179 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV14
		thunder_wedge_damage = 113.0, -- 雷楔伤害
		slash_damage = 378, -- 斩击伤害
		thunderstorm_slash_damage = 189 * 2, -- 雷暴连斩伤害
		cooldown_time = 7.5, -- 冷却时间
	},
	{ -- LV15
		thunder_wedge_damage = 120.0, -- 假设雷楔伤害 (没有明确提供)
		slash_damage = 400, -- 假设斩击伤害 (没有明确提供)
		thunderstorm_slash_damage = 200 * 2, -- 假设雷暴连斩伤害 (没有明确提供)
		cooldown_time = 7.5, -- 冷却时间
	},
}
local BURST_MULT_DATE = {
	{ -- LV1
		skill_damage = 88.0,
		slash_damage = 24.0 * 8,
		final_hit_damage = 189,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV2
		skill_damage = 94.6,
		slash_damage = 25.8 * 8,
		final_hit_damage = 203,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV3
		skill_damage = 101,
		slash_damage = 27.6 * 8,
		final_hit_damage = 217,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV4
		skill_damage = 110,
		slash_damage = 30.0 * 8,
		final_hit_damage = 236,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV5
		skill_damage = 117,
		slash_damage = 31.8 * 8,
		final_hit_damage = 250,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV6
		skill_damage = 123,
		slash_damage = 33.6 * 8,
		final_hit_damage = 264,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV7
		skill_damage = 132,
		slash_damage = 36.0 * 8,
		final_hit_damage = 283,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV8
		skill_damage = 141,
		slash_damage = 38.4 * 8,
		final_hit_damage = 302,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV9
		skill_damage = 150,
		slash_damage = 40.8 * 8,
		final_hit_damage = 321,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV10
		skill_damage = 158,
		slash_damage = 43.2 * 8,
		final_hit_damage = 340,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV11
		skill_damage = 167,
		slash_damage = 45.6 * 8,
		final_hit_damage = 359,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV12
		skill_damage = 176,
		slash_damage = 48.0 * 8,
		final_hit_damage = 378,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV13
		skill_damage = 187,
		slash_damage = 51.0 * 8,
		final_hit_damage = 401,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV14
		skill_damage = 198,
		slash_damage = 54.0 * 8,
		final_hit_damage = 425,
		cooldown_time = 12.0,
		energy_cost = 40,
	},
	{ -- LV15
		skill_damage = 210, -- 假设此为最后一击的LV15技能伤害
		slash_damage = 57.0 * 8, -- 假设此为最后一击的LV15连斩伤害
		final_hit_damage = 450, -- 假设此为最后一击的LV15最后一击伤害
		cooldown_time = 12.0,
		energy_cost = 40,
	},
}
-- --三维
-- TUNING.KEQING_HEALTH = 120
-- TUNING.KEQING_HUNGER = 175
-- TUNING.KEQING_SANITY = 200
-- --TUNING.KEQING_SHOWTAIL = GetModConfigData("showtail")
-- --技能控件
-- TUNING.KEQING_SKILL_KEY = GetModConfigData("skill")
-- TUNING.KEQING_BURST_KEY = GetModConfigData("burst")
--初始物品
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KEQING = { "kq_hairpins" }
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.greensword = {
	atlas = "images/inventoryimages/greensword.xml",
	image = "greensword.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.kq_hairpins = {
	atlas = "images/inventoryimages/kq_hairpins.xml",
	image = "kq_hairpins.tex",
}

TUNING_KEQING = {
	HEALTH = 120,
	HUNGER = 175,
	SANITY = 200,
	DEBUG = false,
	CRIT = true,
	-- 雷楔伤害范围
	SKILL_STULETTO_RANGE = 2,
	-- 连战或者斩击伤害范围
	SKILL_SLASH_RANGE = 4,
	-- 元素爆发伤害范围
	BURST_RANGE = 10,
	SKILL_MULT_DATA = SKILL_MULT_DATA,
	BURST_MULT_DATE = BURST_MULT_DATE,
}
-- TUNING_KEQING.DEBUGMOD.ENABLE = false
