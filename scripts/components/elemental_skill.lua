local function onCurrentCdChange(self, current_cd)
    self.inst.replica.elemental_skill:SetCurrentCd(current_cd)
end
local function onStateChange(self, state)
    self.inst.replica.elemental_skill:SetState(state)
end
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
