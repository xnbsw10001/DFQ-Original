--[[
	desc: Bleed, A buff of Bleed.
	author: SkyFvcker
	since: 2018-9-25
]]--

local _RESMGR = require("actor.resmgr")
local _SOUND = require("lib.sound")
local _ASPECT = require("actor.service.aspect")

local _Gear_Attack = require("actor.gear.attack")
local _Color = require("graphics.drawunit.color")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Bleed : Actor.Buff
---@field protected _color Graphics.Drawunit.Color
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _attack Actor.Gear.Attack
local _Bleed = require("core.class")(_Base)

---@param data Actor.RESMGR.BuffData
function _Bleed.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end
    if (data.sound) then
        data.sound = _RESMGR.GetSoundData(data.sound)
    end

    data.attack = _RESMGR.GetAttackData(data.attack)
end

---@param attack Actor.Gear.Attack
---@param entity Actor.Entity
local function _Collide(attack, entity)
    if (attack._entity == entity) then
        local x, y, z = entity.transform.position:Get()
        return true, x, y, z - math.floor(entity.aspect.height * 0.5)
    end

    return false
end

function _Bleed:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._color = _Color.New(data.color.red, data.color.green, data.color.blue, data.color.alpha)
    self._colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    self._colorTweener:Enter(math.floor(data.time * 0.1), _Color.New(self._color:Get()))

    self._attack = _Gear_Attack.New(entity)
    self._attack:Enter(data.attack, data.attackValue, _, _Collide)

    if (data.sound) then
        _SOUND.Play(data.sound)
    end
end

function _Bleed:OnUpdate(dt)
    self._colorTweener:Update(dt)

    if (not self._colorTweener.isRunning) then
        local target = self._colorTweener:GetTarget() ---@type Graphics.Drawunit.Color

        if (target:Compare(self._color)) then
            target:Set(255, 255, 255, 255)
        else
            target:Set(self._color:Get())
        end

        local time = self._timer.to - self._timer.from
        self._colorTweener:Enter(math.floor(time * 0.1))
    end
end

function _Bleed:Exit()
    if (_Base.Exit(self)) then
        self._attack:Update()
        self._entity.aspect.color:Set(255, 255, 255, 255)
        self._entity.aspect.colorTick = true

        return true
    end

    return false
end

return _Bleed