require("prefabutil")

local cooking = require("cooking")

local assets = {
	Asset("ANIM", "anim/kq_liyuepot.zip"),
	Asset("ANIM", "anim/cook_pot_food.zip"),
	Asset("ANIM", "anim/ui_cookpot_1x4.zip"), --UI
}

local assets_item = {
	Asset("ANIM", "anim/kq_liyuepot.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_liyuepot_item.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_liyuepot_item.xml"),
}

local prefabs = {
	"collapse_small",
	"ash",
	"kq_liyuepot_item",
}

for k, v in pairs(cooking.recipes.portablecookpot) do
	table.insert(prefabs, v.name)
	if v.overridebuild then
		table.insert(assets, Asset("ANIM", "anim/" .. v.overridebuild .. ".zip"))
	end
end

local prefabs_item = {
	"kq_liyuepot_item",
}

local containers = require("containers")
local params = containers.params

--添加食谱
for k, v in pairs(cooking.recipes) do
	if k and v and k ~= "portablespicer" then
		for a, b in pairs(v) do
			if not (b.spice or b.platetype or b.masterfood) then --要把调味料理排除掉,把有盘子的料理排除掉(暴食的)
				local newrecipe = shallowcopy(b) --浅拷贝一份料理数据
				AddCookerRecipe("kq_liyuepot", newrecipe)
			end
		end
	end
end

--为锅添加UI
params.kq_liyuepot = params.cookpot

--收锅
local function ChangeToItem(inst)
	if inst.components.stewer.product ~= nil and inst.components.stewer:IsDone() then
		inst.components.stewer:Harvest()
	end
	if inst.components.container ~= nil then
		inst.components.container:DropEverything()
	end

	local item = SpawnPrefab("kq_liyuepot_item")
	item.Transform:SetPosition(inst.Transform:GetWorldPosition())
	item.AnimState:PlayAnimation("collapse")
	item.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/collapse")
end

local function onhammered(inst) --, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end

	if inst:HasTag("burnt") then
		inst.components.lootdropper:SpawnLootPrefab("ash")
		local fx = SpawnPrefab("collapse_small")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx:SetMaterial("metal")
	else
		ChangeToItem(inst)
	end

	inst:Remove()
end

local function onhit(inst) --, worker)
	if not inst:HasTag("burnt") then
		if inst.components.stewer:IsCooking() then
			inst.AnimState:PlayAnimation("hit_cooking")
			inst.AnimState:PushAnimation("cooking_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
		elseif inst.components.stewer:IsDone() then
			inst.AnimState:PlayAnimation("hit_full")
			inst.AnimState:PushAnimation("idle_full", false)
		else
			if inst.components.container ~= nil and inst.components.container:IsOpen() then
				inst.components.container:Close()
				--onclose will trigger sfx already
			else
				inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
			end
			inst.AnimState:PlayAnimation("hit_empty")
			inst.AnimState:PushAnimation("idle_empty", false)
		end
	end
end

--anim and sound callbacks

local function startcookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_loop", true)
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
		inst.Light:Enable(true)
	end
end

local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_pre_loop")
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then
		if not inst.components.stewer:IsCooking() then
			inst.AnimState:PlayAnimation("idle_empty")
			inst.SoundEmitter:KillSound("snd")
		end
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
	end
end

local function SetProductSymbol(inst, product, overridebuild)
	local recipe = cooking.GetRecipe(inst.prefab, product)
	local potlevel = recipe ~= nil and recipe.potlevel or nil
	local build = (recipe ~= nil and recipe.overridebuild) or overridebuild or "cook_pot_food"
	local overridesymbol = (recipe ~= nil and recipe.overridesymbolname) or product
	if potlevel == "high" then
		inst.AnimState:Show("swap_high")
		inst.AnimState:Hide("swap_mid")
		inst.AnimState:Hide("swap_low")
	elseif potlevel == "low" then
		inst.AnimState:Hide("swap_high")
		inst.AnimState:Hide("swap_mid")
		inst.AnimState:Show("swap_low")
	else
		inst.AnimState:Hide("swap_high")
		inst.AnimState:Show("swap_mid")
		inst.AnimState:Hide("swap_low")
	end
	inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
end

local function spoilfn(inst)
	if not inst:HasTag("burnt") then
		inst.components.stewer.product = inst.components.stewer.spoiledproduct
		SetProductSymbol(inst, inst.components.stewer.product)
	end
end

local function ShowProduct(inst)
	if not inst:HasTag("burnt") then
		local product = inst.components.stewer.product
		SetProductSymbol(inst, product, IsModCookingProduct(inst.prefab, product) and product or nil)
	end
end

local function donecookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_pst")
		inst.AnimState:PushAnimation("idle_full", false)
		ShowProduct(inst)
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
		inst.Light:Enable(false)
	end
end

local function continuedonefn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle_full")
		ShowProduct(inst)
	end
end

local function continuecookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_loop", true)
		inst.Light:Enable(true)
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	end
end

local function harvestfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle_empty")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
	end
end

local function getstatus(inst)
	return (inst:HasTag("burnt") and "BURNT")
		or (inst.components.stewer:IsDone() and "DONE")
		or (not inst.components.stewer:IsCooking() and "EMPTY")
		or (inst.components.stewer:GetTimeToCook() > 15 and "COOKING_LONG")
		or "COOKING_SHORT"
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data ~= nil and data.burnt then
		inst.components.burnable.onburnt(inst)
	end
end

local function OnDismantle(inst) --, doer)
	ChangeToItem(inst)
	inst:Remove()
end

local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)
	RemovePhysicsColliders(inst)
	SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
	if inst.components.workable ~= nil then
		inst:RemoveComponent("workable")
	end
	if inst.components.portablestructure ~= nil then
		inst:RemoveComponent("portablestructure")
	end
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:ListenForEvent("animover", ErodeAway)
	inst.AnimState:PlayAnimation("burnt_collapse")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(0.5)
	MakeObstaclePhysics(inst, inst.physicsradiusoverride)

	inst.MiniMapEntity:SetIcon("kq_liyuepot_item.tex")

	inst.Light:Enable(false)
	inst.Light:SetRadius(0.6)
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(0.5)
	inst.Light:SetColour(235 / 255, 62 / 255, 12 / 255)

	inst.DynamicShadow:SetSize(2, 1)

	inst:AddTag("structure")

	--stewer (from stewer component) added to pristine state for optimization
	inst:AddTag("stewer")

	inst.AnimState:SetBank("kq_liyuepot")
	inst.AnimState:SetBuild("kq_liyuepot")
	inst.AnimState:PlayAnimation("idle_empty")
	inst.scrapbook_anim = "idle_empty"

	inst:SetPrefabNameOverride("kq_liyuepot_item")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("portablestructure")
	inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

	inst:AddComponent("stewer")
	inst.components.stewer.cooktimemult = TUNING.PORTABLE_COOK_POT_TIME_MULTIPLIER
	inst.components.stewer.onstartcooking = startcookfn
	inst.components.stewer.oncontinuecooking = continuecookfn
	inst.components.stewer.oncontinuedone = continuedonefn
	inst.components.stewer.ondonecooking = donecookfn
	inst.components.stewer.onharvest = harvestfn
	inst.components.stewer.onspoil = spoilfn

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("kq_liyuepot")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose
	inst.components.container.skipclosesnd = true
	inst.components.container.skipopensnd = true

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	MakeMediumBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	inst.components.burnable:SetFXLevel(2)
	inst.components.burnable:SetOnBurntFn(OnBurnt)

	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

---------------------------------------------------------------
---------------- Inventory Portable Cookpot -------------------
---------------------------------------------------------------

local function ondeploy(inst, pt, deployer)
	local pot = SpawnPrefab("kq_liyuepot")
	if pot ~= nil then
		pot.Physics:SetCollides(false)
		pot.Physics:Teleport(pt.x, 0, pt.z)
		pot.Physics:SetCollides(true)
		pot.AnimState:PlayAnimation("place")
		pot.AnimState:PushAnimation("idle_empty", false)
		pot.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/place")
		inst:Remove()
		PreventCharacterCollisionsWithPlacedObjects(pot)
	end
end

local function itemfn()
	local assetname = "kq_liyuepot"
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle_ground")
	inst.scrapbook_anim = "idle_ground"

	inst:AddTag("portableitem")

	MakeInventoryFloatable(inst, "med", 0.1, 0.8)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "kq_liyuepot_item"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kq_liyuepot_item.xml" --物品贴图

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	MakeMediumBurnable(inst)
	MakeSmallPropagator(inst)

	return inst
end

return Prefab("kq_liyuepot", fn, assets, prefabs),
	MakePlacer("kq_liyuepot_item_placer", "kq_liyuepot", "kq_liyuepot", "idle_empty"),
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
	Prefab("kq_liyuepot_item", itemfn, assets_item, prefabs_item)
