## Notes
```
	local damage = (basedamage or 0)
        * (basemultiplier or 1)
        * externaldamagemultipliers:Get()
		* damagetypemult
        * (multiplier or 1)
        * playermultiplier
        * pvpmultiplier
		* (self.customdamagemultfn ~= nil and self.customdamagemultfn(self.inst, target, weapon, multiplier, mount) or 1)
        + (bonus or 0)
```
basedamage 一般来说是武器获取
basemultiplier 用于骑牛
externaldamagemultipliers 角色的倍率，例如刚子就是2，当然看条件，骑牛时看牛的定义
damagetypemult 类型加成
multiplier 这个参数传入的倍率
playermultiplier 是否开启玩家伤害
pvp_damagemod 这个是pvp的倍率
```
  local playermultiplier = target ~= nil and (target:HasTag("player") or target:HasTag("player_damagescale"))
    local pvpmultiplier = playermultiplier and self.inst:HasTag("player") and self.pvp_damagemod or 1
```
customdamagemultfn 警钟那种根据玩家状态给与倍率 默认为1



## Log
- 2025-03-31
  finish the basic layout for the new ult
  待做 伤害计算逻辑重写，不再依赖武器，仅计算攻击力。我想想要不要附加武器特效就是了
  闪避调整，体力条，连续2次限制，动画可能还要协调一点
- 2025-04-02
 伤害计算重做初步完整？
 接下来加上暴击和增伤区间设定
 要不要加附加伤害？后续算倍率，damagebonus 这个不吃倍率
 增伤那得全算啊，暴击也得，这样符合原作

 - 2025-04-19
    伤害计算完成
    暴击和增伤区间设定完成
    附加伤害其实不好做，因为原本的算法是直接乘算，有点傻x，实在不行后续hook combat吧