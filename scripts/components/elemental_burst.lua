-- local DoSkillAreaDmg = require("lib/utils").DoSkillAreaDmg
-- 该组件处理cd和能量，以及三部分大招造成伤害的逻辑，方便sg直接调用
local Elemental_Burst = Class(function(self, inst)
    self.inst = inst
    self.skill_cd = 12.0 -- 默认冷却时间
    self.max_energy = 40.0 -- 默认最大能量
    self.energy_cost = 40.0 -- 默认能量消耗
    self.current_cd = 0.0 -- 当前冷却时间
    self.current_energy = 0.0 -- 当前能量
    self.state = 0 -- 技能状态
end)
function Elemental_Burst:OnSave()
    return {
        current_cd = self.current_cd,
        current_energy = self.current_energy
    }
end
function Elemental_Burst:OnLoad(data)
    if data ~= nil then
        self.current_cd = data.current_cd or self.skill_cd
        self.current_energy = data.current_energy or self.current_energy
        if self.current_cd > 0 then
            self.inst:StartUpdatingComponent(self)
        end
    end
end
function Elemental_Burst:OnUpdate(dt)
    self.current_cd = self.current_cd - dt
    if self.current_cd <= 0 then
        self.current_cd = 0
        self.inst:StopUpdatingComponent(self)
    end
end

function Elemental_Burst:GetSkillCd(cd)
    return self.current_cd
end
function Elemental_Burst:SetSkillCd(cd)
    if cd == nil then
        self.current_cd = self.skill_cd
    else
        self.current_cd = cd
    end
    self.inst:StartUpdatingComponent(self)
end

function Elemental_Burst:DoSkill(stage)
    -- 一段斩击
    local skill_dmg_mult = 1.87
    local slash_dmg_mult = 0.51
    local last_dmg_mult = 4.01
    local range = 10
    --- 8次连斩
    --- 最后一段斩击
    local x, y, z = self.inst.Transform:GetWorldPosition()
    if stage == "skill" then
        -- 这里大概加个转变鱼肉吧
        self.inst.components.keqing_aoe_dmg:DoAoeAttack(skill_dmg_mult, range, x, y, z)
    elseif stage == "slash" then
        self.inst.components.keqing_aoe_dmg:DoAoeAttack(slash_dmg_mult, range, x, y, z)
    elseif stage == "last" then
        self.inst.components.keqing_aoe_dmg:DoAoeAttack(last_dmg_mult, range, x, y, z)
    end
end

return Elemental_Burst
