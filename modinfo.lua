-- This information tells other players more about the mod
name = "[DST]霆霓快雨——刻晴" ---mod名字
description =
	"感谢订阅本mod！\nThank you for your subscription!\n璃月七星之一，玉衡星，刻晴。她对[帝君一言而决的璃月]颇有微词——但实际上，神挺欣赏她这样的人。" --mod描述
author = "eins, 初心风笛" --作者
version = "0.3.5.2" -- mod版本 上传mod需要两次的版本不一样

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
--forumthread = "/files/file/950-extended-sample-character/"

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true --兼容联机

-- Not compatible with Don't Starve
dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

-- Character mods need this set to true
all_clients_require_mod = true --所有人mod

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = --服务器标签
	{
		"character",
		"keqing",
		"genshin impact",
	}

local keys = {
	"B",
	"C",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"N",
	"O",
	"Q",
	"R",
	"T",
	"V",
	"X",
	"Z",
	"LAlt",
	"RAlt",
	"LCtrl",
	"RCtrl",
	"LShift",
	"RShift",
	"LALT",
	"RALT",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
}
local list = {}
local string = ""
for i = 1, #keys do
	list[i] = { description = "Key " .. string.upper(keys[i]), data = "KEY_" .. string.upper(keys[i]) }
end

--mod设置
configuration_options = {
	{
		name = "skill",
		label = "元素战技快捷键",
		hover = "",
		options = list,
		default = "KEY_Z",
	},
	{
		name = "burst",
		label = "元素爆发快捷键",
		hover = "",
		options = list,
		default = "KEY_X",
	},
}
