GLOBAL.setmetatable(env, {__index = function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddRoom("kq_stoneamber",
{
	colour = {r = 1.5 , g = 1 , b = .8 , a = .50},
	value = GROUND.ROCKY,
	contents =
	{
		countprefabs =	--必定会出现对应数量的物品的表
		{
			kq_stoneamber = function () return 25 + math.random(15) end,
		},
		distributepercent = 0.25, -- distributeprefabs就是按比例
		distributeprefabs =
		{
		    kq_stoneamber = 0.1,
		},
	}
})

AddTaskPreInit("terrain_rocky", function(task)
    task.room_choices["kq_stoneamber"] = 20
end)

AddRoomPreInit("TallbirdNests",function(self)
    if self.contents and self.contents.distributeprefabs then
        self.contents.distributeprefabs.kq_stoneamber = 0.2
    end
end)

AddRoomPreInit("Rocky",function(self)
    if self.contents and self.contents.distributeprefabs then
        self.contents.distributeprefabs.kq_stoneamber = 0.2
    end
end)

AddRoomPreInit("RockyBuzzards",function(self)
    if self.contents and self.contents.distributeprefabs then
        self.contents.distributeprefabs.kq_stoneamber = 0.2
    end
end)

AddRoomPreInit("BGRocky",function(self)
    if self.contents and self.contents.distributeprefabs then
        self.contents.distributeprefabs.kq_stoneamber = 0.2
    end
end)

-- AddRoom("NewRoom", {
--     colour={r=.1,g=.8,b=.1,a=.50}, -- colour不用管，不重要
--     value = GLOBAL.GROUND.GRASS, -- value那个是定义地皮类型
--     contents =  { --contents是设置具体有什么东西再你设置的这个区域里
-- 		--应该是蘑菇怪圈，也是一种方便我们验证地形是否生成的办法？
--         -- countstaticlayouts={ -- countstaticlayouts是彩蛋的设置
--         --     ["MushroomRingSmall"]=function()
--         --     if math.random(0,1000) > 985 then
--         --         return 1
--         --     end
--         --     return 0
--         -- end},
--         countprefabs = { --countprefabs适用于你想添加几个东西，按个数计算
--             caomeibush = 1, --暂时测试使用，酒架  
--         },
--         distributepercent = 0.25,  --distributeprefabs就是按比例
--         distributeprefabs= {
--             spiderden=0.003,
-- 			sapling=0.0001,
-- 			twiggytree = 0.0001,
-- 			ground_twigs = 0.00003,
-- 			pond_mos=0.005,
-- 			reeds=0.005,
-- 			tentacle=0.095,
--             caomeibush = 0.05,
-- 			marsh_bush=0.05,
-- 			marsh_tree=0.05,
-- 			blue_mushroom = .01,
-- 			mermhouse=0.004,
--         },
--     },
-- })

-- local function AddNewRoom(task)
--     task.room_choices["NewRoom"] = 1
-- end
-- AddTaskPreInit("Squeltch", AddNewRoom)