--[[
	desc: HitBomb, A buff of hitBomb.
	author: Musoucrow
    since: 2019-4-8
    alter: 2019-10-8
]]--

local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _RESMGR = require("actor.resmgr")
local _BATTLE = require("actor.service.battle")

local _Color = require("graphics.drawunit.color")
local _Tweener = require("util.gear.tweener")
local _Timer = require("util.gear.timer")
local _Base = require("actor.buff.base")

---@class Actor.Buff.HitBomb : Actor.Buff
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _actorData Actor.RESMGR.InstanceData
---@field protected _attackValue Actor.Gear.Attack.AttackValue
---@field protected _hitCount int
---@field protected _shake table
---@field protected _soundData SoundData
---@field protected _bombTimer Util.Gear.Timer
---@field public hitMax int
local _HitBomb = require("core.class")(_Base)

---@param self Actor.Buff.HitBomb
local function _OnHit(self)
    if (self._bombTimer.isRunning) then
        return
    end

    self._hitCount = self._hitCount + 1
    
    if (self._hitCount == self.hitMax - 1) then
        local s = self._shake
        _BATTLE.Shake(self._entity.battle, s.time, s.xa, s.xb, s.ya, s.yb)
        _SOUND.Play(self._soundData)
    elseif (self._hitCount >= self.hitMax) then
        self._hitCount = 0
        self._bombTimer:Enter()

        local pos = self._entity.transform.position
        local param = {
            x = pos.x,
            y = pos.y,
            z = pos.z - math.floor(self._entity.aspect.height * 0.5),
            entity = self._entity,
            attackValue = self._attackValue
        }

        _FACTORY.New(self._actorData, param)
    end

    local alpha = math.floor(255 * (self._hitCount / self.hitMax))
    self._colorTweener:GetTarget().alpha = alpha
    self._colorTweener:Enter()
end

---@param data Actor.RESMGR.BuffData
function _HitBomb.HandleData(data)
    data.actor = _RESMGR.GetInstanceData(data.actor)
    data.sound = _RESMGR.GetSoundData(data.sound)
end

function _HitBomb:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._colorTweener = _Tweener.New(entity.aspect.pureColor)
    self._colorTweener:SetTarget(_Color.New(data.color.red, data.color.green, data.color.blue, 0))
    self._colorTweener:SetTime(200)

    self._actorData = data.actor
    self._attackValue = data.attackValue
    self._shake = data.shake
    self._soundData = data.sound

    self._bombTimer = _Timer.New(data.interval)
    self.hitMax = data.hitMax
    self._hitCount = 0

    self._entity.attacker.hitCaller:AddListener(self, _OnHit)
    self._entity.battle.beatenCaller:AddListener(self, _OnHit)
end

function _HitBomb:OnUpdate(dt)
    if (not self._entity.identity.isPaused) then
        self._colorTweener:Update(dt)
        self._bombTimer:Update(dt)
    end
end

function _HitBomb:Exit()
    if (_Base.Exit(self)) then
        self._entity.attacker.hitCaller:DelListener(self, _OnHit)
        self._entity.battle.beatenCaller:DelListener(self, _OnHit)
        self._entity.aspect.pureColor.alpha = 0

        return true
    end

    return false
end

return _HitBomb