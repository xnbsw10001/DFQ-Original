--[[
	desc: Blink, A buff of blink
	author: Musoucrow
    since: 2019-6-20
]]--

local _ASPECT = require("actor.service.aspect")

local _Color = require("graphics.drawunit.color")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Blink : Actor.Buff
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _banAttack boolean
---@field protected _alpha int
local _Blink = require("core.class")(_Base)

function _Blink:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._alpha = data.alpha

    local color = _Color.New(entity.aspect.color:Get())
    color.alpha = 0

    self._colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    self._colorTweener:SetTarget(color)
    self._colorTweener:Enter(data.interval)

    self._banAttack = false

    self._entity.battle.banCountMap.hide = self._entity.battle.banCountMap.hide + 1
end

function _Blink:OnUpdate(dt)
    self._colorTweener:Update(dt)

    if (not self._colorTweener.isRunning) then
        local target = self._colorTweener:GetTarget()
        target.alpha = target.alpha == 255 and 0 or 255
        self._colorTweener:Enter()
    end

    if (self._entity.aspect.color.alpha <= self._alpha and not self._banAttack) then
        self._banAttack = true
        self._entity.battle.banCountMap.attack = self._entity.battle.banCountMap.attack + 1
    elseif (self._entity.aspect.color.alpha > self._alpha and self._banAttack) then
        self._banAttack = false
        self._entity.battle.banCountMap.attack = self._entity.battle.banCountMap.attack - 1
    end
end

function _Blink:Exit()
    if (_Base.Exit(self)) then
        self._entity.aspect.color.alpha = 255
        self._entity.aspect.colorTick = true

        if (self._banAttack) then
            self._entity.battle.banCountMap.attack = self._entity.battle.banCountMap.attack - 1
        end

        self._entity.battle.banCountMap.hide = self._entity.battle.banCountMap.hide - 1
    end
end

return _Blink