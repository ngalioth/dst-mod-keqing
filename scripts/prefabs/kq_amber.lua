local assets = {
	Asset("ANIM", "anim/kq_amber.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_amber.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_amber.xml"),
	Asset("ANIM", "anim/kq_stoneamber.zip"),
	Asset("ANIM", "anim/kq_lightamber.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_lightamber.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_lightamber.xml"),
}

local stoneloot = { "rocks", "rocks", "rocks", "rocks", "rocks", "rocks", "kq_amber", "kq_amber" } -- 掉落物

local lightloot = { "kq_amber", "kq_amber", "rocks", "rocks", "goldnugget", "goldnugget" }

local function OnWorked(inst, worker, workleft)
	if workleft <= 0 then
		local pos = inst:GetPosition()
		SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
		inst.components.lootdropper:DropLoot(pos)
		inst:Remove()
	else
		inst.AnimState:PlayAnimation(
			(workleft < TUNING.ROCKS_MINE / 3 and "low") or (workleft < TUNING.ROCKS_MINE * 2 / 3 and "med") or "full"
		)
	end
end

local function OnlightWorked(inst, worker, workleft)
	if workleft <= 0 then
		local pos = inst:GetPosition()
		SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
		inst.components.lootdropper:DropLoot(pos)
		inst:Remove()
	end
end

local function onsave(inst, data)
	data.stage = inst.stage
end

local function onload(inst, data)
	if data ~= nil and data.stage ~= nil then
		inst.stage = data.stage
	end
end

local function ondeploy(inst, pt)
	local lightamber = SpawnPrefab("kq_lightamber")
	if lightamber ~= nil then
		lightamber.Physics:SetCollides(false)
		lightamber.Physics:Teleport(pt.x, 0, pt.z)
		lightamber.Physics:SetCollides(true)
		lightamber.AnimState:PlayAnimation("idle")
		inst:Remove()
		--PreventCharacterCollisionsWithPlacedObjects(lightamber)
	end
end

function Amberfn()
	local assetname = "kq_amber"

	local inst = CreateEntity() -- 创建实体
	inst.entity:AddTransform() -- 添加xyz形变对象
	inst.entity:AddAnimState() -- 添加动画状态
	inst.entity:AddNetwork() -- 添加这一行才能让所有客户端都能看到这个实体

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname) -- 地上动画
	inst.AnimState:SetBuild(assetname) -- 材质包，就是anim里的zip包
	inst.AnimState:PlayAnimation("idle") -- 默认播放哪个动画

	MakeInventoryFloatable(inst)

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable") -- 可检查组件
	inst:AddComponent("inventoryitem") -- 物品组件
	inst.components.inventoryitem.imagename = "kq_amber" -- 在背包里的贴图
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_amber.xml" -- 在背包里的贴图
	inst.scrapbook_anim = assetname

	inst:AddComponent("stackable") -- 可堆叠
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	MakeHauntableLaunch(inst)

	return inst
end

local function stoneamber_fn()
	local assetname = "kq_stoneamber"
	local inst = CreateEntity() -- 创建实体

	inst.entity:AddTransform() -- 添加xyz形变对象
	inst.entity:AddSoundEmitter() -- 添加声音组件
	inst.entity:AddAnimState() -- 添加动画文件
	inst.entity:AddMiniMapEntity() -- 添加小地图图标
	inst.entity:AddNetwork() -- 添加网络

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("full") -- 默认播放哪个动画

	inst.scrapbook_anim = "initial"

	MakeObstaclePhysics(inst, 1) -- 添加阻挡

	inst.MiniMapEntity:SetIcon("kq_stoneamber.tex") -- 小地图图标

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(stoneloot)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(OnWorked)

	inst:AddComponent("inspectable")

	inst.OnSave = onsave
	inst.OnLoad = onload

	MakeSnowCovered(inst)

	MakeHauntableWork(inst)

	return inst
end

local function lightamber()
	local assetname = "kq_lightamber"
	local inst = CreateEntity() -- 创建实体

	inst.entity:AddTransform() -- 添加xyz形变对象
	inst.entity:AddSoundEmitter() -- 添加声音组件
	inst.entity:AddAnimState() -- 添加动画文件
	inst.entity:AddMiniMapEntity() -- 添加小地图图标
	inst.entity:AddNetwork() -- 添加网络
	inst.entity:AddLight() -- 添加光照
	inst.entity:AddPhysics() -- 添加物理效果

	inst.Light:Enable(true)
	inst.Light:SetColour(250 / 255, 157 / 255, 116 / 255) -- 添加光的RGB属性
	inst.Light:SetRadius(8) -- 光的半径
	inst.Light:SetFalloff(0.5) -- 光的衰减程度（百分比）
	inst.Light:SetIntensity(0.7) -- 光强（百分比，光在中心的集中程度）

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle") -- 默认播放哪个动画

	MakeObstaclePhysics(inst, 1) -- 添加阻挡

	inst.MiniMapEntity:SetIcon("kq_lightamber.tex") -- 小地图图标

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("inspectable") -- 可以检查

	inst:AddComponent("deployable") -- 可放置
	inst.components.deployable.ondeploy = ondeploy

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(lightloot)

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnWorkCallback(OnlightWorked)

	MakeSnowCovered(inst)

	MakeHauntableWork(inst)

	return inst
end

return Prefab("kq_amber", Amberfn, assets),
	Prefab("kq_stoneamber", stoneamber_fn, assets),
	Prefab("kq_lightamber", lightamber, assets),
	MakePlacer("kq_lightamber_placer", "kq_lightamber", "kq_lightamber", "idle")
--MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn)
--name：放置物的Prefab名，一般约定为原Prefab名_placer
--bank：放置物的Bank
--build：放置物的Build
--anim：放置物用于播放的动画，一般约定为idle
--onground：取值为true或false，是否设置为紧贴地面。请参考前面AnimState的内容
--snap：取值为true或false，这个参数目前无用，设置为nil即可
--metersnap：取值为true或false，与围墙有关，一般建筑物用不上，设置为nil即可。
--scale：缩放大小
--fixedcameraoffset：固定偏移
--facing：设置有几个面，参考AnimState的内容
--postinit_fn：特殊处理
