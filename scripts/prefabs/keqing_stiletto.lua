local assets = {
	Asset("ANIM", "anim/leixie.zip"),
}

-- 雷楔怎么着也应该是个特效，不是实体，不跟随主体的特效
local function create()
	local assetname = "leixie"

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.Transform:SetNoFaced() --只有一个面
	inst.entity:AddAnimState()
	inst.AnimState:SetBank(assetname) --动画集合
	inst.AnimState:SetBuild(assetname) --Prefab的材质
	inst.AnimState:PlayAnimation("idle") --动画播放

	inst.entity:AddLight() --添加光照
	inst.Light:Enable(true) -- 添加光的RGB属性
	inst.Light:SetColour(192 / 255, 128 / 255, 254 / 255)
	inst.Light:SetRadius(1) --光的半径
	inst.Light:SetFalloff(0.5) --光的衰减程度（百分比）
	inst.Light:SetIntensity(0.7) --光强（百分比，光在中心的集中程度）

	inst.entity:AddPhysics() --添加物理属性

	inst.entity:AddNetwork() --添加网络属性

	inst:AddTag("FX")
	inst.entity:SetPristine()
	inst.persists = false
	inst:DoTaskInTime(5, function()
		inst:Remove()
	end)

	if not TheWorld.ismastersim then
		return inst
	end

	--添加音效组件，没素材，摸了
	--inst.entity.AddSoundEmitter()
	--inst.SoundEmitter:PlaySound("path","name")
	--inst.SoundEmitter:KillSound("name")
	--inst.entity:AddDynamicShadow()

	return inst
end

return Prefab("keqing_stiletto", create, assets)
