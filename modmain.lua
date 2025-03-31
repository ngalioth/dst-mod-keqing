PrefabFiles =
{
	"keqing",  --人物代码文件
    "leixie", --雷楔
    "kq_food",
    "kq_specialfish", -- 绝境求生烤鱼
    "kq_liyuepot", --锅
    "greensword", --绿剑
    "kq_shrimp", -- 虾
    "kq_amber", -- 石珀
    "kq_foodbag", -- 便携营养袋 
    "kq_backpack", -- 刻刻猫猫包包
    "kq_skill_fx", -- 元素战技特效
    "kq_burst_fx", -- 元素爆发特效
    "kq_hairpins", -- 发簪
    "kq_lightstone", -- 流明石触媒
    "kq_elecfur", -- 奇特的羽毛
    "kq_hotbottle", -- 放热瓶
    --"kq_coldbottle", -- 放冷瓶
    "kq_hotcore", -- 常燃火种
    "kq_coldcore", -- 极寒之核
    "kq_foxmirror", -- 留念镜
    "kq_redfun", -- 红羽团扇
    "kq_windbottle", -- 捕风瓶
    "kq_splitrock", -- 镇石断片
    "kq_ladytomb", -- 戴丧面具
    "kq_whitetwigs", -- 初生白枝
    "kq_dragonblood", -- 深邃之血
    "kq_books", -- 书
    "kq_telepole", -- 电线杆
    "kq_tailing_fx", -- 拖尾
    "keqing_fx",
}

---对比老版本 主要是增加了names图片 人物检查图标 还有人物的手臂修复（增加了上臂）
--人物动画里面有个SWAP_ICON 里面的图片是在检查时候人物头像那里显示用的
----2019.05.08 修复了 人物大图显示错误和检查图标显示错误

Assets =
{
    Asset( "IMAGE", "images/saveslot_portraits/keqing.tex" ), --存档图片
    Asset( "ATLAS", "images/saveslot_portraits/keqing.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/keqing.tex" ), --单机选人界面
    Asset( "ATLAS", "images/selectscreen_portraits/keqing.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/keqing_silho.tex" ), --单机未解锁界面
    Asset( "ATLAS", "images/selectscreen_portraits/keqing_silho.xml" ),

    Asset( "IMAGE", "bigportraits/keqing.tex" ), --人物大图（方形的那个）
    Asset( "ATLAS", "bigportraits/keqing.xml" ),

	Asset( "IMAGE", "images/map_icons/keqing.tex" ), --小地图
	Asset( "ATLAS", "images/map_icons/keqing.xml" ),

    Asset( "IMAGE", "images/map_icons/kq_liyuepot_item.tex"),
    Asset( "ATLAS", "images/map_icons/kq_liyuepot_item.xml"),

    Asset( "IMAGE", "images/map_icons/kq_stoneamber.tex"),
    Asset( "ATLAS", "images/map_icons/kq_stoneamber.xml"),

    Asset( "IMAGE", "images/map_icons/kq_lightamber.tex"),
    Asset( "ATLAS", "images/map_icons/kq_lightamber.xml"),

	Asset( "IMAGE", "images/avatars/avatar_keqing.tex" ), --tab键人物列表显示的头像
    Asset( "ATLAS", "images/avatars/avatar_keqing.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_ghost_keqing.tex" ),--tab键人物列表显示的头像（死亡）
    Asset( "ATLAS", "images/avatars/avatar_ghost_keqing.xml" ),

	Asset( "IMAGE", "images/avatars/self_inspect_keqing.tex" ), --人物检查按钮的图片
    Asset( "ATLAS", "images/avatars/self_inspect_keqing.xml" ),

	Asset( "IMAGE", "images/names_keqing.tex" ),  --人物名字
    Asset( "ATLAS", "images/names_keqing.xml" ),

    Asset( "IMAGE", "bigportraits/keqing_none.tex" ),  --人物大图（椭圆的那个）
    Asset( "ATLAS", "bigportraits/keqing_none.xml" ),

    Asset( "IMAGE", "images/inventoryimages/kq_amber.tex"), -- 石珀
    Asset( "ATLAS", "images/inventoryimages/kq_amber.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_lightamber.tex"), -- 石珀
    Asset( "ATLAS", "images/inventoryimages/kq_lightamber.xml"),

    Asset( "IMAGE", "images/food/kq_friedegg.tex"), -- 煎蛋
    Asset( "ATLAS", "images/food/kq_friedegg.xml"),

    Asset( "IMAGE", "images/food/kq_goldenshrimp.tex"), -- 刻晴诱捕器
    Asset( "ATLAS", "images/food/kq_goldenshrimp.xml"),

    Asset( "IMAGE", "images/inventoryimages/greensword.tex"), -- 磐岩结绿
    Asset( "ATLAS", "images/inventoryimages/greensword.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_backpack.tex"), --刻刻猫猫包包
    Asset( "ATLAS", "images/inventoryimages/kq_backpack.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_foodbag.tex"), -- 便携营养袋
    Asset( "ATLAS", "images/inventoryimages/kq_foodbag.xml"),

    Asset( "IMAGE", "images/food/kq_specialfish.tex"), -- 绝境求生烤鱼
    Asset( "ATLAS", "images/food/kq_specialfish.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_liyuepot_item.tex"), -- 便携锅
    Asset( "ATLAS", "images/inventoryimages/kq_liyuepot_item.xml"),

    Asset( "IMAGE", "images/food/kq_pocketcake.tex"), -- 口袋饼
    Asset( "ATLAS", "images/food/kq_pocketcake.xml"),

    Asset( "IMAGE", "images/food/kq_shrimp.tex"), -- 虾
    Asset( "ATLAS", "images/food/kq_shrimp.xml"),

    Asset( "IMAGE", "images/food/kq_cookedshrimp.tex"), -- 熟虾
    Asset( "ATLAS", "images/food/kq_cookedshrimp.xml"),

    Asset( "IMAGE", "images/food/kq_deadshrimp.tex"), -- 虾仁
    Asset( "ATLAS", "images/food/kq_deadshrimp.xml"),

    Asset( "IMAGE", "images/food/kq_cookeddeadshrimp.tex"), -- 熟虾仁
    Asset( "ATLAS", "images/food/kq_cookeddeadshrimp.xml"),

    Asset( "IMAGE", "images/food/kq_shrimphead.tex"), -- 虾头
    Asset( "ATLAS", "images/food/kq_shrimphead.xml"),

    Asset( "IMAGE", "images/food/kq_steamedshrimphead.tex"), -- 蒸虾头
    Asset( "ATLAS", "images/food/kq_steamedshrimphead.xml"),

    Asset( "IMAGE", "images/food/kq_grilledfish.tex"), -- 烤吃虎鱼
    Asset( "ATLAS", "images/food/kq_grilledfish.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_hairpins.tex"), -- 发簪
    Asset( "ATLAS", "images/inventoryimages/kq_hairpins.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_lightstone.tex"), -- 流明石触媒
    Asset( "ATLAS", "images/inventoryimages/kq_lightstone.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_elecfur.tex"), -- 奇特的羽毛
    Asset( "ATLAS", "images/inventoryimages/kq_elecfur.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_hotbottle.tex"), -- 放热瓶
    Asset( "ATLAS", "images/inventoryimages/kq_hotbottle.xml"),

    --Asset( "IMAGE", "images/inventoryimages/kq_coldbottle.tex"), -- 放冷瓶
    --Asset( "ATLAS", "images/inventoryimages/kq_coldbottle.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_hotcore.tex"), -- 常燃火种
    Asset( "ATLAS", "images/inventoryimages/kq_hotcore.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_coldcore.tex"), -- 极寒之核
    Asset( "ATLAS", "images/inventoryimages/kq_coldcore.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_foxmirror.tex"), -- 留念镜
    Asset( "ATLAS", "images/inventoryimages/kq_foxmirror.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_redfun.tex"), -- 红羽团扇
    Asset( "ATLAS", "images/inventoryimages/kq_redfun.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_windbottle.tex"), -- 捕风瓶
    Asset( "ATLAS", "images/inventoryimages/kq_windbottle.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_splitrock.tex"), -- 镇石断片
    Asset( "ATLAS", "images/inventoryimages/kq_splitrock.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_ladytomb.tex"), -- 戴丧面具
    Asset( "ATLAS", "images/inventoryimages/kq_ladytomb.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_whitetwigs.tex"), -- 初生白枝
    Asset( "ATLAS", "images/inventoryimages/kq_whitetwigs.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_dragonblood.tex"), -- 深邃之血
    Asset( "ATLAS", "images/inventoryimages/kq_dragonblood.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_42.tex"), -- 永恒领域游览指南
    Asset( "ATLAS", "images/inventoryimages/kq_42.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_eclipse.tex"), -- 日月前事
    Asset( "ATLAS", "images/inventoryimages/kq_eclipse.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_fischer.tex"), -- 菲谢尔皇女夜谭
    Asset( "ATLAS", "images/inventoryimages/kq_fischer.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_peppapig.tex"), -- 野猪公主·卷一
    Asset( "ATLAS", "images/inventoryimages/kq_peppapig.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_qqlangpoem.tex"), -- 丘丘语诗歌选
    Asset( "ATLAS", "images/inventoryimages/kq_qqlangpoem.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_qqlookup.tex"), -- 丘丘语速查手册
    Asset( "ATLAS", "images/inventoryimages/kq_qqlookup.xml"),

    Asset( "IMAGE", "images/inventoryimages/kq_telepole.tex"), -- 电线杆
    Asset( "ATLAS", "images/inventoryimages/kq_telepole.xml"),

    Asset( "IMAGE", "images/skills/skill0.tex" ), -- 元素战技技能图标1
    Asset( "ATLAS", "images/skills/skill0.xml" ),

    Asset( "IMAGE", "images/skills/skill1.tex" ), -- 元素战技技能图标2
    Asset( "ATLAS", "images/skills/skill1.xml" ),

    Asset( "ANIM", "anim/energy.zip"), -- 技能图标

    Asset( "IMAGE", "images/kq_tailing.tex" ), --拖尾
    Asset( "ATLAS", "images/kq_tailing.xml" ),
}
--[[---注意事项
1、目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
2、官方人物目前的图片跟名字是分开的 
3、names_keqing 和 keqing_none 这两个文件需要特别注意！！！
这两文件每一次重新转换之后！需要到对应的xml里面改对应的名字 否则游戏里面无法显示
具体为：
将names_keqing.xml 里面的 Element name="keqing.tex" （也就是去掉names——）
将keqing_none.xml 里面的 Element name="keqing_none_oval" 也就是后面要加  _oval
（注意看修改的名字！不是两个都需要修改）
]]

--local require = GLOBAL.require
--local STRINGS = GLOBAL.STRINGS
GLOBAL.setmetatable(env, {__index = function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

GLOBAL.SoraAPI = env
modimport('scripts/skins.lua')

modimport('main/strings.lua')

AddMinimapAtlas("images/map_icons/keqing.xml")  --增加小地图图标
AddMinimapAtlas("images/map_icons/kq_liyuepot_item.xml")  --增加小地图图标
AddMinimapAtlas("images/map_icons/kq_stoneamber.xml")  --增加小地图图标
AddMinimapAtlas("images/map_icons/kq_lightamber.xml")  --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("keqing", "FEMALE")

--三维
TUNING.KEQING_HEALTH = 120
TUNING.KEQING_HUNGER = 175
TUNING.KEQING_SANITY = 200
--TUNING.KEQING_SHOWTAIL = GetModConfigData("showtail")
--技能控件
TUNING.KEQING_SKILL_KEY = GetModConfigData("skill")
TUNING.KEQING_BURST_KEY = GetModConfigData("burst")
--初始物品
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KEQING = {"greensword", "kq_hairpins"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.greensword =
{
	atlas = "images/inventoryimages/greensword.xml",
	image = "greensword.tex"
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.kq_hairpins =
{
	atlas = "images/inventoryimages/kq_hairpins.xml",
	image = "kq_hairpins.tex"
}

-- 添加技能的UI
local skill = require("widgets/skill")
local burst = require("widgets/burst")
AddClassPostConstruct("widgets/controls", function(self)
	if self.owner and self.owner.prefab == "keqing" then
		self.skill = self:AddChild(skill(self.owner))
		self.burst = self:AddChild(burst(self.owner))
	end
end)

modimport('main/recipes.lua')
-- modimport('main/uidrag.lua')
modimport('main/stategraphs.lua')
modimport('main/postinits.lua')
modimport('scripts/main.lua')
modimport('scripts/sg.lua')