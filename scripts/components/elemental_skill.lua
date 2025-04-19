local SKILL_MULT_DATA = {{ -- LV1
    thunder_wedge_damage = 50.0, -- 雷楔伤害
    slash_damage = 168, -- 斩击伤害
    thunderstorm_slash_damage = 84.0 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV2
    thunder_wedge_damage = 54.2, -- 雷楔伤害
    slash_damage = 181, -- 斩击伤害
    thunderstorm_slash_damage = 90.3 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV3
    thunder_wedge_damage = 58.0, -- 雷楔伤害
    slash_damage = 193, -- 斩击伤害
    thunderstorm_slash_damage = 96.6 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV4
    thunder_wedge_damage = 63.0, -- 雷楔伤害
    slash_damage = 210, -- 斩击伤害
    thunderstorm_slash_damage = 105 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV5
    thunder_wedge_damage = 66.8, -- 雷楔伤害
    slash_damage = 223, -- 斩击伤害
    thunderstorm_slash_damage = 111 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV6
    thunder_wedge_damage = 70.6, -- 雷楔伤害
    slash_damage = 235, -- 斩击伤害
    thunderstorm_slash_damage = 118 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV7
    thunder_wedge_damage = 75.6, -- 雷楔伤害
    slash_damage = 252, -- 斩击伤害
    thunderstorm_slash_damage = 126 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV8
    thunder_wedge_damage = 80.6, -- 雷楔伤害
    slash_damage = 269, -- 斩击伤害
    thunderstorm_slash_damage = 134 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV9
    thunder_wedge_damage = 86.0, -- 雷楔伤害
    slash_damage = 286, -- 斩击伤害
    thunderstorm_slash_damage = 143 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV10
    thunder_wedge_damage = 90.7, -- 雷楔伤害
    slash_damage = 302, -- 斩击伤害
    thunderstorm_slash_damage = 151 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV11
    thunder_wedge_damage = 95.8, -- 雷楔伤害
    slash_damage = 319, -- 斩击伤害
    thunderstorm_slash_damage = 160 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV12
    thunder_wedge_damage = 101.0, -- 雷楔伤害
    slash_damage = 336, -- 斩击伤害
    thunderstorm_slash_damage = 168 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV13
    thunder_wedge_damage = 107.0, -- 雷楔伤害
    slash_damage = 357, -- 斩击伤害
    thunderstorm_slash_damage = 179 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV14
    thunder_wedge_damage = 113.0, -- 雷楔伤害
    slash_damage = 378, -- 斩击伤害
    thunderstorm_slash_damage = 189 * 2, -- 雷暴连斩伤害
    cooldown_time = 7.5 -- 冷却时间
}, { -- LV15
    thunder_wedge_damage = 120.0, -- 假设雷楔伤害 (没有明确提供)
    slash_damage = 400, -- 假设斩击伤害 (没有明确提供)
    thunderstorm_slash_damage = 200 * 2, -- 假设雷暴连斩伤害 (没有明确提供)
    cooldown_time = 7.5 -- 冷却时间
}}

local function onCurrentCdChange(self, current_cd)
    self.inst.replica.elemental_skill:SetCurrentCd(current_cd)
end
local function onStateChange(self, state)
    self.inst.replica.elemental_skill:SetState(state)
end

-- 该组件管理战技的cd、能量、冷却时间、技能等级，管理雷楔，下线应当消失重置状态的
local Elemental_Skill = Class(function(self, inst)
    self.inst = inst
    self.skill_cd = 7.5 -- 默认冷却时间 7.5s 释放state进入2,5s内释放第二段，否则直接转回状态0，雷楔失效 当然可选引爆直接转回状态0
    self.current_cd = 0.0 -- 当前冷却时间
    self.state = false -- 技能状态 处理二段战技 不进行保存
end, nil, {
    current_cd = onCurrentCdChange,
    state = onStateChange
})
function Elemental_Skill:OnSave()
    return {
        current_cd = self.current_cd
    }
end
function Elemental_Skill:OnLoad(data)
    if data ~= nil then
        self.current_cd = data.current_cd or self.skill_cd
        self.current_energy = data.current_energy or self.current_energy
        if self.current_cd > 0 then
            self.inst:StartUpdatingComponent(self)
        end
    end
end
function Elemental_Skill:OnUpdate(dt)
    self.current_cd = self.current_cd - dt
    if self.current_cd <= 2.5 then
        self.state = false -- 二段状态失效，进入cd
    end
    if self.current_cd <= 0 then
        self.current_cd = 0
        self.inst:StopUpdatingComponent(self)
    end
end
