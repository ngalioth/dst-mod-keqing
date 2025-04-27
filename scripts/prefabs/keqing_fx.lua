local burst_assets = { Asset("ANIM", "anim/kq_burst_chop.zip") }
local burst_begin_assets = { Asset("ANIM", "anim/kq_burst_begin.zip") }

local FXs = {
	{
		name = "keqing_burst_1_fx",
		bank = "kq_burst_chop",
		build = "kq_burst_chop",
		anim = "idle_1",
		assets = burst_assets,
	},
	{
		name = "keqing_burst_2_fx",
		bank = "kq_burst_chop",
		build = "kq_burst_chop",
		anim = "idle_2",
		assets = burst_assets,
	},
	{
		name = "keqing_burst_3_fx",
		bank = "kq_burst_chop",
		build = "kq_burst_chop",
		anim = "idle_3",
		assets = burst_assets,
	},
	{
		name = "keqing_burst_end_fx",
		bank = "kq_burst_chop",
		build = "kq_burst_chop",
		anim = "end",
		assets = burst_assets,
	},
	{
		name = "keqing_burst_vanish_fx",
		bank = "kq_burst_begin",
		build = "kq_burst_begin",
		anim = "idle",
		assets = burst_begin_assets,
	},
}
local function MakeFx(name, bank, build, anim, assets)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddPhysics() -- 添加物理属性
		inst.entity:AddNetwork() -- 添加网络属性
		inst.entity:AddFollower()

		inst.Transform:SetNoFaced() -- 只有一个面
		inst.Transform:SetScale(1.5, 1.5, 1.5) -- 设置大小
		inst.AnimState:SetBank(bank) -- 动画集合
		inst.AnimState:SetBuild(build) -- Prefab的材质
		inst.AnimState:PlayAnimation(anim) -- 动画播放

		inst:AddTag("FX")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		-- 添加监听器清除实体
		inst:ListenForEvent("animover", inst.Remove)

		return inst
	end
	return Prefab(name, fn, assets)
end
local prefabs = {}
for _, fx in ipairs(FXs) do
	table.insert(prefabs, MakeFx(fx.name, fx.bank, fx.build, fx.anim, fx.assets))
end
return unpack(prefabs)
