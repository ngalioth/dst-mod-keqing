local SourceModifierList = require("util/sourcemodifierlist")
local SpDamageUtil = require("components/spdamageutil")

-- 给池塘添加虾
AddPrefabPostInit("pond", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    if inst.components.fishable ~= nil then
        inst.components.fishable:AddFish("kq_shrimp")
        inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
    end
end)

-- 给龙蝇和巨鹿添加掉落物
AddPrefabPostInit("dragonfly", function (inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("kq_hotcore", 1.0)
    end
end)

AddPrefabPostInit("deerclops", function (inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("kq_coldcore", 1.0)
    end
end)

--去除沙漠目镜的滤镜显示
AddClassPostConstruct("widgets/gogglesover", function(self , owner)
    local ToggleGoggles_old = self.ToggleGoggles
    self.ToggleGoggles = function(self,show, ...)
        ToggleGoggles_old(self, show, ...)
        if self.owner and self.owner.replica.inventory:EquipHasTag("goggles") then
            self.inst.entity:Hide(false)
        end
    end
end)

-- 冻结免疫
AddComponentPostInit("freezable",function(self)
    for k, v in ipairs({"AddColdness", "Freeze"}) do
        local old = self[v]
        self[v] = function (self, ...)
            if self.inst.components.inventory and self.inst.components.inventory:EquipHasTag("kq_antifreeze") then
                return
            else
                return old(self, ...)
            end
        end
    end
end)

-- 催眠免疫
AddComponentPostInit("sleeper",function(self)
    for k, v in ipairs({"AddSleepiness", "GoToSleep"}) do
        local old = self[v]
        self[v] = function (self, ...)
            if self.inst.components.inventory and self.inst.components.inventory:EquipHasTag("kq_antisleep") then
                return
            else
                return old(self, ...)
            end
        end
    end
end)
AddComponentPostInit("grogginess",function(self)
    for k, v in ipairs({"AddGrogginess", "groggy"}) do
        local old = self[v]
        self[v] = function (self, ...)
            if self.inst.components.inventory and self.inst.components.inventory:EquipHasTag("kq_antisleep") then
                return
            else
                return old(self, ...)
            end
        end
    end
end)

local moddir = KnownModIndex:GetModsToLoad(true)
local enablemods = {}

for k, dir in pairs(moddir) do
    local info = KnownModIndex:GetModInfo(dir)
    local name = info and info.name or "unknow"
    enablemods[dir] = name
end
-- MOD是否开启
function IsModEnable(name)
    for k, v in pairs(enablemods) do
        if v and (k:match(name) or v:match(name)) then return true end
    end
    return false
end

-- 兼容智能锅mod
if IsModEnable("727774324") then
    AddCookingPot('kq_liyuepot')
end

-- 元素反应mod未开启时
if not IsModEnable("2578151314") then
    AddComponentPostInit("combat", function (self)
        function self:CalcDamage(target, weapon, multiplier)
            if target:HasTag("alwaysblock") then
                return 0
            end
            local basedamage
            local basemultiplier = self.damagemultiplier
            local externaldamagemultipliers = self.externaldamagemultipliers
            local damagetypemult = 1
            local bonus = self.damagebonus --not affected by multipliers
            local playermultiplier = target ~= nil and target:HasTag("player")
            local pvpmultiplier = playermultiplier and self.inst:HasTag("player") and self.pvp_damagemod or 1
            local mount = nil
            local spdamage
            local crit = 0
            local critdmg = 1.0
            --NOTE: playermultiplier is for damage towards players
            --      generally only applies for NPCs attacking players
            if weapon ~= nil then
                --No playermultiplier when using weapons
                basedamage, spdamage = weapon.components.weapon:GetDamage(self.inst, target)
                playermultiplier = 1
                --#V2C: entity's own damagetypebonus stacks with weapon's damagetypebonus
                if self.inst.components.damagetypebonus ~= nil then
                    damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
                end
                --#DiogoW: entity's own SpDamage stacks with weapon's SpDamage
                spdamage = SpDamageUtil.CollectSpDamage(self.inst, spdamage)
                if weapon.components.kq_crit and self.inst.components.kq_crit then
                    crit = weapon.components.kq_crit:GetCrit() + self.inst.components.kq_crit:GetCrit()
                    if math.random() <= crit then
                        critdmg = critdmg + weapon.components.kq_crit:GetCritdmg() + self.inst.components.kq_crit:GetCritdmg()
                    end
                end
            else
                basedamage = self.defaultdamage
                playermultiplier = playermultiplier and self.playerdamagepercent or 1
                if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
                    mount = self.inst.components.rider:GetMount()
                    if mount ~= nil and mount.components.combat ~= nil then
                        basedamage = mount.components.combat.defaultdamage
                        basemultiplier = mount.components.combat.damagemultiplier
                        externaldamagemultipliers = mount.components.combat.externaldamagemultipliers
                        bonus = mount.components.combat.damagebonus
                        if mount.components.damagetypebonus ~= nil then
                            damagetypemult = mount.components.damagetypebonus:GetBonus(target)
                        end
                        spdamage = SpDamageUtil.CollectSpDamage(mount, spdamage)
                    else
                        if self.inst.components.damagetypebonus ~= nil then
                            damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
                        end
                        spdamage = SpDamageUtil.CollectSpDamage(self.inst, spdamage)
                    end
                    local saddle = self.inst.components.rider:GetSaddle()
                    if saddle ~= nil and saddle.components.saddler ~= nil then
                        basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
                        if saddle.components.damagetypebonus ~= nil then
                            damagetypemult = damagetypemult * saddle.components.damagetypebonus:GetBonus(target)
                        end
                        spdamage = SpDamageUtil.CollectSpDamage(saddle, spdamage)
                    end
                else
                    if self.inst.components.damagetypebonus ~= nil then
                        damagetypemult = self.inst.components.damagetypebonus:GetBonus(target)
                    end
                    spdamage = SpDamageUtil.CollectSpDamage(self.inst, spdamage)
                end
            end
            local damage = (basedamage or 0)
                * (basemultiplier or 1)
                * externaldamagemultipliers:Get()
                * damagetypemult
                * (multiplier or 1)
                * playermultiplier
                * pvpmultiplier
                * (self.customdamagemultfn ~= nil and self.customdamagemultfn(self.inst, target, weapon, multiplier, mount) or 1)
                + (bonus or 0)
            if spdamage ~= nil then
                local spmult =
                    damagetypemult *
                    --playermultiplier * --@V2C excluded to avoid tuning nightmare
                    pvpmultiplier
                if spmult ~= 1 then
                    spdamage = SpDamageUtil.ApplyMult(spdamage, spmult)
                end
                for i, v in ipairs(spdamage) do
                    spdamage[i] = spdamage[i] * critdmg
                end
            end
            damage = damage * critdmg
            return damage, spdamage
        end
    end)
end

AddStategraphPostInit("wilson", function (inst)
    local framenum = 0
    local states =
    {
        State{
            name = "veryquickcastspell",
            tags = { "doing", "busy", "canrotate" },
            onenter = function(inst)
                inst.components.locomotor:Stop()
                if not(inst.components.inventory and inst.components.inventory:EquipHasTag("greensword")) then
                    framenum = 9
                    if inst.components.rider:IsRiding() then
                        inst.AnimState:PlayAnimation("player_atk_pre")
                        inst.AnimState:PushAnimation("player_atk", false)
                    else
                        inst.AnimState:PlayAnimation("atk_pre")
                        inst.AnimState:PushAnimation("atk", false)
                    end
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end,
            timeline =
            {
                TimeEvent(framenum * FRAMES, function(inst)
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("busy")
                end),
                TimeEvent((framenum + 2) * FRAMES, function(inst)
                    inst.sg:GoToState("idle")
                end),
            },
            events =
            {
                EventHandler("animqueueover", function(inst)
                    if inst.AnimState:AnimDone() then
                        inst.sg:GoToState("idle")
                    end
                end),
            },
        },
    }
    for k, v in pairs(states) do
        assert(v:is_a(State), "Non-state added in mod state table!")
        inst.states[v.name] = v
    end
end)