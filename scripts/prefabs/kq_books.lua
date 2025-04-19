local assets42 = {
	Asset("ANIM", "anim/kq_42.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_42.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_42.xml"),
}

local assetseclipse = {
	Asset("ANIM", "anim/kq_eclipse.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_eclipse.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_eclipse.xml"),
}

local assetsfischer = {
	Asset("ANIM", "anim/kq_fischer.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_fischer.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_fischer.xml"),
}

local assetspeppa = {
	Asset("ANIM", "anim/kq_peppapig.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_peppapig.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_peppapig.xml"),
}

local assetspoem = {
	Asset("ANIM", "anim/kq_qqlangpoem.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_qqlangpoem.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_qqlangpoem.xml"),
}

local assetslookup = {
	Asset("ANIM", "anim/kq_qqlookup.zip"),
	Asset("IMAGE", "images/inventoryimages/kq_qqlookup.tex"),
	Asset("ATLAS", "images/inventoryimages/kq_qqlookup.xml"),
}

local function read42(inst, reader)
	if reader.peruse_42 then
		reader.peruse_42(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_42"))
	return true
end

local function kq_42fn(inst, reader)
	--打开小地图
	local x, y, z = reader.Transform:GetWorldPosition()
	local rotation = reader:GetRotation()
	local reveal_center = Vector3(x, 0, z)
		+ Vector3(150 * math.cos(rotation * DEGREES), 0, -150 * math.sin(rotation * DEGREES))
	local cx, _, cz = reveal_center:Get()
	if reader.player_classified ~= nil then
		reader.player_classified.revealmapspot_worldx:set(cx)
		reader.player_classified.revealmapspot_worldz:set(cz)
		reader.player_classified.revealmapspotevent:push()
	end
	--驱散地图迷雾
	for angle = rotation - 180, rotation + 180, 2 do
		local offset = Vector3(10 * math.cos(angle * DEGREES), 0, -10 * math.sin(angle * DEGREES))
		local iterpos = Vector3(x, y, z)
		local num_iter = 200
		repeat
			iterpos = iterpos + offset
			local ix, _, iz = iterpos:Get()
			if reader.player_classified then
				reader.player_classified.MapExplorer:RevealArea(ix, 0, iz)
			end
			num_iter = num_iter - 10
		until num_iter <= 0
	end
	return true
end

local function eclipse(inst, reader)
	if reader.peruse_eclipse then
		reader.peruse_eclipse(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_ECLIPSE"))
	return true
end

local function kq_eclipsefn(inst, reader)
	if TheWorld:HasTag("cave") then
		return false, "NOMOONINCAVES"
	elseif TheWorld.state.moonphase == "new" then
		return false, "ALREADYNEWMOON"
	end
	TheWorld:PushEvent("ms_setmoonphase", { moonphase = "new", iswaxing = true })
	if not TheWorld.state.isnight then
		reader.components.talker:Say(GetString(reader, "ANNOUNCE_BOOK_MOON_DAYTIME"))
	end
	return true
end

local function fischer(inst, reader)
	if reader.peruse_fischer then
		reader.peruse_fischer(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_FISCHER"))
	return true
end

local function kq_fischerfn(inst, reader)
	local x, y, z = reader.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12, { "heavy" })
	local boss = nil
	for i, ent in ipairs(ents) do
		local result1 = string.match(ent.prefab, "([^_]+)_")
		if result1 ~= nil and result1 == "chesspiece" or ent.prefab == "chesspiece_guardianphase3" then
			local x0, y0, z0 = ent.Transform:GetWorldPosition()
			local result2 = string.match(ent.prefab, "_([^_]+)_") or string.match(ent.prefab, "_(%a+)$")
			if result2 ~= nil or ent.prefab == "chesspiece_guardianphase3" then
				local result3
				if result2 ~= nil then
					result3 = string.gsub(result2, "%d+$", "")
				end
				if result3 ~= nil or ent.prefab == "chesspiece_guardianphase3" then
					local final
					if result3 ~= nil then
						final = result3
					end
					if final == "rook" or final == "knight" or final == "bishop" then
						final = "shadow_" .. final
					end
					if final == "moosegoose" then
						final = "moose"
					end
					if final == "toadstool" then
						final = final .. "_dark"
					end
					if final == "claywarg" then
						final = "warg"
					end
					if final == "clayhound" then
						final = "hound"
					end
					if final == "manrabbit" then
						final = "bunnyman"
					end
					if final == "twinsofterror" then
						final = "twinofterror1"
					end
					if ent.prefab == "chesspiece_guardianphase3" then
						final = "alterguardian_phase2"
					end
					boss = SpawnPrefab(final)
					if boss ~= nil then
						boss.Transform:SetPosition(x0, y0, z0)
						ent:Remove()
					end
					if final == "twinofterror1" then
						local boss1 = SpawnPrefab("twinofterror2")
						if boss1 ~= nil then
							boss1.Transform:SetPosition(x0, y0, z0)
						end
					end
				end
			end
		end
	end
	if boss == nil then
		return false
	end
	return true
end

local function peppa(inst, reader)
	if reader.peruse_peppa then
		reader.peruse_peppa(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_PEPPAPIG"))
	return true
end

local LEIFTARGET_ONEOF_TAGS = { "evergreens", "birchnut" }
local LEIFTARGET_CANT_TAGS = { "leif", "fire", "stump", "burnt", "monster", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function CanTransformIntoLeifTest(target)
	return (
		target:HasTag("evergreens")
		and not target.noleif
		and target.components.growable ~= nil
		and target.components.growable.stage <= 3
	)
		or (
			target:HasTag("birchnut")
			and target.leaf_state ~= "barren"
			and not target.monster
			and target.monster_start_task == nil
			and target.monster_stop_task == nil
			and target.domonsterstop_task == nil
		)
end

local function DelayedStartMonster(inst)
	inst.monster_start_task = nil
	inst:StartMonster()
end

local function WakeUpLeif(ent)
	ent.components.sleeper:WakeUp()
end

local function WakeUpNearbyLeifs(x, y, z, doer)
	local ents = TheSim:FindEntities(x, y, z, TUNING.LEIF_REAWAKEN_RADIUS, { "leif" })
	for i, v in ipairs(ents) do
		if v.components.sleeper ~= nil and v.components.sleeper:IsAsleep() then
			v:DoTaskInTime(math.random(), WakeUpLeif)
		end
		if doer ~= nil then
			v.components.combat:SuggestTarget(doer)
		end
	end
end

local function SpawnNewLeifs(x, y, z, doer, num_spawns)
	local ents = TheSim:FindEntities(
		x,
		y,
		z,
		TUNING.LEIF_IDOL_SPAWN_RADIUS,
		{ "tree" },
		LEIFTARGET_CANT_TAGS,
		LEIFTARGET_ONEOF_TAGS
	)
	for i, ent in ipairs(ents) do
		if CanTransformIntoLeifTest(ent) then
			if ent.TransformIntoLeif ~= nil then
				ent:TransformIntoLeif(doer)
				num_spawns = num_spawns - 1
			elseif ent.StartMonster ~= nil then
				ent.monster_start_task = ent:DoTaskInTime(math.random(1, 4), DelayedStartMonster)
				num_spawns = num_spawns - 1
			end
			if num_spawns <= 0 then
				break
			end
		end
	end
end

local function kq_peppafn(inst, reader)
	local x, y, z = reader.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12)
	local triggered = false
	for i, ent in ipairs(ents) do
		if ent.prefab == "pigman" or ent.prefab == "pigguard" then
			triggered = true
			ent.components.werebeast:TriggerDelta(4)
		end
		if ent.prefab == "bunnyman" then
			triggered = true
			ent.components.timer:StartTimer("forcenightmare", 240)
		end
		if ent:HasTag("evergreens") or ent:HasTag("birchnut") then
			triggered = true
			WakeUpNearbyLeifs(x, y, z, reader)
			SpawnNewLeifs(x, y, z, reader, 4)
		end
	end
	return triggered
end

local function qqlangpoem(inst, reader)
	if reader.peruse_qqlangpoem then
		reader.peruse_qqlangpoem(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_QQLANGPOEM"))
	return true
end

local function kq_qqlangfn(inst, reader)
	local x, y, z = reader.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12, { "_combat" })
	local cnt = 0
	for i, ent in ipairs(ents) do
		if cnt < 3 then
			if ent.components.follower ~= nil and ent.components.follower ~= reader then
				if ent.prefab == "pigman" or ent.prefab == "bunnyman" or ent.prefab == "merm" then
					ent.components.follower:SetLeader(reader)
					ent.components.follower:AddLoyaltyTime(480)
					cnt = cnt + 1
				end
			end
		end
	end
	if cnt == 0 then
		return false
	end
	return true
end

local function qqlookup(inst, reader)
	if reader.peruse_qqlookup then
		reader.peruse_qqlookup(reader)
	end
	reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_QQLOOKUP"))
	return true
end

local function kq_qqlookupfn(inst, reader)
	local x, y, z = reader.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 12, { "_combat" })
	local triggered = false
	for i, ent in ipairs(ents) do
		if ent.prefab == "monkey" or ent.prefab == "powder_monkey" then
			triggered = true
			ent.components.health:DoDelta(-999)
		end
		if ent.components.combat.target == reader then
			triggered = true
			ent.components.combat:DropTarget()
		end
	end
	return triggered
end

local function commonfn(name, fn, perusefn, uses)
	local assetname = name
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank(assetname)
	inst.AnimState:SetBuild(assetname)
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("book")
	inst:AddTag("bookcabinet_item")
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = name
	inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. name .. ".xml" --物品贴图
	inst:AddComponent("book")
	inst.components.book:SetOnRead(fn)
	inst.components.book:SetOnPeruse(perusefn)
	inst.components.book:SetReadSanity(0)
	inst.components.book:SetPeruseSanity(0)
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(uses) -- 设置最大耐久MaxUse
	inst.components.finiteuses:SetUses(uses)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)

	--MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
	MakeHauntableLaunch(inst)

	return inst
end

local function book_42()
	local inst = commonfn("kq_42", kq_42fn, read42, 3)
	return inst
end

local function book_eclipse()
	local inst = commonfn("kq_eclipse", kq_eclipsefn, eclipse, 3)
	return inst
end

local function book_fischer()
	local inst = commonfn("kq_fischer", kq_fischerfn, fischer, 1)
	return inst
end

local function book_peppapig()
	local inst = commonfn("kq_peppapig", kq_peppafn, peppa, 5)
	return inst
end

local function book_qqlangpoem()
	local inst = commonfn("kq_qqlangpoem", kq_qqlangfn, qqlangpoem, 3)
	return inst
end

local function book_qqlookup()
	local inst = commonfn("kq_qqlookup", kq_qqlookupfn, qqlookup, 5)
	return inst
end

return Prefab("kq_42", book_42, assets42),
	Prefab("kq_eclipse", book_eclipse, assetseclipse),
	Prefab("kq_fischer", book_fischer, assetsfischer),
	Prefab("kq_peppapig", book_peppapig, assetspeppa),
	Prefab("kq_qqlangpoem", book_qqlangpoem, assetspoem),
	Prefab("kq_qqlookup", book_qqlookup, assetslookup)
