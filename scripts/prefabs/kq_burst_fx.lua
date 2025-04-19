local assets = {
	Asset("ANIM", "anim/kq_burst_fx.zip"),
}

local function fn()
	local assetname = "kq_burst_fx"
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics() -- 添加物理属性
	inst.entity:AddNetwork() -- 添加网络属性
	inst.entity:AddFollower()

	inst.Transform:SetNoFaced() -- 只有一个面
	inst.Transform:SetScale(2, 2, 2) -- 设置大小
	inst.AnimState:SetBank(assetname) --动画集合
	inst.AnimState:SetBuild(assetname) --Prefab的材质
	inst.AnimState:PlayAnimation(assetname) --动画播放

	inst:AddTag("FX")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	--添加监听器清除实体
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("kq_burst_fx", fn, assets)
