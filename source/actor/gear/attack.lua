--[[
	desc: Attack, a gear for battle business.
	author: Musoucrow
	since: 2018-12-24
	alter: 2019-9-5
]]--

local _CONFIG = require("config")
local _TIME = require("lib.time")
local _TABLE = require("lib.table")
local _SOUND = require("lib.sound")
local _MAP = require("map.init")
local _ECSMGR = require("actor.ecsmgr")
local _FACTORY = require("actor.factory")
local _RESMGR = require("actor.resmgr")
local _WORLD = require("actor.world")
local _BATTLE = require("actor.service.battle")
local _STATE = require("actor.service.state")
local _ASPECT = require("actor.service.aspect")
local _BUFF = require("actor.service.buff")

local _Color = require("graphics.drawunit.color")
local _Timer = require("util.gear.timer")
local _SolidRect = require("graphics.drawunit.solidRect")
local _Gear = require("core.gear")

---@class Actor.Gear.Attack.AttackValue
---@field public damage int
---@field public damageRate number
---@field public isPhysical boolean
---@field public isCritical boolean
---@field public noDef boolean

---@class Actor.Gear.Attack:Core.Gear
---@field protected _entity Actor.Entity
---@field protected _attributes Actor.Component.Attributes
---@field protected _hasAttackedMap table<Actor.Entity, int>
---@field protected _hasAttacked boolean
---@field public damage int
---@field public isCritical boolean
---@field public isPhysical boolean
---@field public noDef boolean
---@field public hitstop milli
---@field public selfstop milli
---@field public direction direction
---@field public noFlash boolean
---@field public noSound boolean
---@field public camp int
---@field public element string
---@field public shake table
---@field public screenShake table
---@field public overturn table
---@field public flight table
---@field public stun table
---@field public effectSet table
---@field public soundDataSet table
---@field public buffDataSet table<int, Actor.RESMGR.BuffData>
---@field public color Graphics.Drawunit.Color
---@field public collision table<Actor.Component.Aspect, string>
---@field public Collide function
---@field public Hit function
---@field public isView boolean
---@field public timer Util.Gear.Timer
---@field public isOnce boolean
---@field public disableAttack boolean
local _Attack = require("core.class")(_Gear)
_Attack.enable = true

local _defaultCollision = {body = "attack"}
local _criticalSoundData = _RESMGR.GetSoundData("dead")
local _list = _ECSMGR.NewComboList({
    transform = true,
    aspect = true,
    battle = true,
    attacker = true
})

local _elementEffectGroup = {
    fire = _RESMGR.GetInstanceData("effect/hitting/fire"),
    water = _RESMGR.GetInstanceData("effect/hitting/water"),
    light = _RESMGR.GetInstanceData("effect/hitting/light"),
    dark = _RESMGR.GetInstanceData("effect/hitting/dark")
}

local _elementColorGroup = {
    none = _Color.New(),
    fire = _Color.New(255, 120, 0),
    water = _Color.New(0, 150, 255),
    light = _Color.New(0, 255, 255),
    dark = _Color.New(230, 0, 255)
}

local _elementSoundGroup = {
    fire = _RESMGR.GetSoundData("hitting/fire"),
    water = _RESMGR.GetSoundData("hitting/water"),
    light = _RESMGR.GetSoundData("hitting/light"),
    dark = _RESMGR.GetSoundData("hitting/dark")
}

local _effectPool = {}
local _counterEffectData = _RESMGR.GetInstanceData("effect/hitting/counter")
local _meta = {__mode = 'k'}

---@param entity Actor.Entity
---@return boolean
local function _IsPlayer(entity)
    if (entity == _CONFIG.user.player) then
        return true
    elseif (entity.identity.superior) then
        return entity.identity.superior == _CONFIG.user.player
    end
end

---@param data Actor.RESMGR.InstanceData
---@param param table
---@return Actor.Entity
local function _NewEffect(data, param)
    if (not _effectPool[data]) then
        _effectPool[data] = {}
    end

    return _FACTORY.NewWithPool(data, param, _effectPool[data])
end

local function _OnClean()
    _effectPool = {}
end

---@param attack Actor.Gear.Attack
---@param enemy Actor.Entity
function _Attack.DefaultCollide(attack, enemy)
    if (attack._entity == enemy) then
        return false
    end

    local beaten = _ASPECT.GetBodySolidRectList(enemy.aspect)

    for k, v in pairs(attack.collision) do
        local collider = k:GetCollider()

        if (collider) then
            local isdone, x, y, z

            if (type(v) == "string") then
                local attack = collider:GetList(v)
                isdone, x, y, z = _SolidRect.CollideWithList(beaten, attack)
            else
                for n=1, #v do
                    local attack = collider:GetList(v[n])
                    isdone, x, y, z = _SolidRect.CollideWithList(beaten, attack)

                    if (isdone) then
                        break
                    end
                end
            end

            if (isdone) then
                return isdone, x, y, z
            end
        end
    end

    return false
end

function _Attack.Init()
    _MAP.AddLoadListener(self, _OnClean)
end

---@param entity Actor.Entity
function _Attack:Ctor(entity)
    _Gear.Ctor(self)

    self._entity = entity
    self.shake = {}
    self.screenShake = {}
    self.overturn = {}
    self.flight = {}
    self.stun = {}
    self.effectSet = {}
    self.soundDataSet = {}
    self.buffDataSet = {}
    self.collision = {}
    self.color = _Color.New()
    self.timer = _Timer.New()
    self._hasAttacked = false

    self._hasAttackedMap = {}
    setmetatable(self._hasAttackedMap, _meta)
end

function _Attack:Update(dt)
    if (not self.isRunning or not self._entity.attacker.enable or not _Attack.enable) then
        return
    end

    if (self.timer.isRunning) then
        dt = dt or _TIME.GetDelta()
        self.timer:Update(dt)

        if (not self.timer.isRunning) then
            self:Reload()
            self.timer:Enter()
        end
    end

    local noCollider = true

    for k, v in pairs(self.collision) do
        local collider = k:GetCollider()
        
        if (collider) then
            noCollider = false
            break
        end
    end

    if (noCollider) then
        return
    end

    local isPlayer = _IsPlayer(self._entity)

    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity
        local camp = self.camp == 0 or self.camp ~= e.battle.camp

        if (e.battle.banCountMap.attack == 0 and e.battle.deadProcess == 0 and camp and self._hasAttackedMap[e] == nil) then
            local isdone, x, y, z, ax, direction, isCritical = self:Collide(e)
            direction = direction or self._entity.transform.direction

            if (isdone) then
                ax = ax or self._entity.transform.position.x
                local turnDirection = self.direction
                isCritical = isCritical or self.isCritical
                isCritical = isCritical or math.random() <= self._attributes.criticalRate

                if (turnDirection) then
                    turnDirection = turnDirection * direction
                end

                local isTurn = _BATTLE.Turn(e.transform, e.battle, ax, turnDirection)

                if (isTurn and e ~= _CONFIG.user.player) then
                    isCritical = true
                end
                
                local hitDirection = -e.transform.direction

                if (self.hitstop) then
                    local hitstop = isCritical and self.hitstop * 2 or self.hitstop
                    _BATTLE.Hitstop(e.attacker, e.identity, hitstop, self.disableAttack)
                end

                if (self.selfstop) then
                    local selfstop = isCritical and self.selfstop * 2 or self.selfstop
                    _BATTLE.Hitstop(self._entity.attacker, self._entity.identity, selfstop)
                end

                if (not self.noFlash) then
                    _BATTLE.Flash(e.battle, self.color:Get())
                end

                if (self.shake.time) then
                    _BATTLE.Shake(e.battle, self.shake.time, self.shake.xa, self.shake.xb, self.shake.ya, self.shake.yb)
                end

                if (self.screenShake.time) then
                    local ss = self.screenShake
                    _MAP.camera:Shake(ss.time, ss.xa, ss.xb, ss.ya, ss.yb)
                end

                if (e.states) then
                    local hasOverturn = false
                    local hasFlight = false

                    if (self.overturn.movingTime) then
                        local overturn = self.overturn
                        local pos = self.overturn.bySelf and e.transform.position or self._entity.transform.position
                        local dir = self.overturn.bySelf and e.transform.direction or direction
                        local ox = pos.x + overturn.x * dir
                        local oy = pos.y + overturn.y
                        local oz = pos.z + overturn.z

                        hasOverturn = _BATTLE.Overturn(e.battle, e.states, ox, oy, oz, overturn.movingTime,
                                overturn.delayTime, overturn.easing, overturn.flight, overturn.flags, overturn.Func)
                    end

                    if (not hasOverturn and self.flight.power_z) then
                        local flight = self.flight
                        local flightDirection = flight.direction and flight.direction * hitDirection or hitDirection

                        if (not flight.inFlight or (flight.inFlight and _STATE.HasTag(e.states, "flight"))) then
                            hasFlight = _BATTLE.Flight(e.battle, e.states, flight.power_z, flight.speed_up, flight.speed_down,
                                    flight.power_x, flight.speed_x, flightDirection, flight.flags, flight.Func)
                        end
                    end

                    if (not hasFlight and self.stun.time) then
                        if (e.transform.position.z < 0 and _STATE.HasTag(e.states, "jump")) then
                            _BATTLE.Flight(e.battle, e.states)
                        else
                            local stun = self.stun
                            local stunDirection = stun.direction and stun.direction * hitDirection or hitDirection
    
                            _BATTLE.Stun(e.battle, e.states, stun.time, stun.power, stun.speed, stunDirection, stun.flags, stun.Func)
                        end
                    end
                end
                
                local param = {
                    x = x,
                    y = e.transform.position.y,
                    z = z,
                    direction = direction,
                    entity = e
                }

                for n=1, #self.effectSet do
                    if (#self.effectSet[n] > 0) then
                        local m = math.random(1, #self.effectSet[n])
                        _NewEffect(self.effectSet[n][m], param)
                    else
                        _NewEffect(self.effectSet[n], param)
                    end
                end

                if (self.element) then
                    _NewEffect(_elementEffectGroup[self.element], param)
                    _SOUND.Play(_elementSoundGroup[self.element])
                end
                
                for n=1, #self.soundDataSet do
                    if (type(self.soundDataSet[n]) == "table") then
                        local m = math.random(1, #self.soundDataSet[n])
                        _SOUND.Play(self.soundDataSet[n][m])
                    else
                        _SOUND.Play(self.soundDataSet[n])
                    end
                end

                if (not self.noSound and e.battle.dmgSoundDatas and e.battle.banCountMap.dmgSound == 0) then
                    _SOUND.RandomPlay(e.battle.dmgSoundDatas)
                end

                for n=1, #self.buffDataSet do
                    _BUFF.AddBuff(e, self.buffDataSet[n])
                end
                
                local damageRate = 1

                if (e.attributes and not self.noDef) then
                    local def = self.isPhysical and e.attributes.phyDef or e.attributes.magDef
                    damageRate = math.abs(1 - (def * 0.001))
                end
                
                local damage = math.floor(self.damage * damageRate)
                damage = isCritical and math.floor(damage * 1.5) or damage
                
                local beatenConfig = e.battle.beatenConfig
                beatenConfig.position:Set(x, y, z)
                beatenConfig.damage = damage
                beatenConfig.isPhysical = self.isPhysical
                beatenConfig.isCritical = isCritical
                beatenConfig.isTurn = isTurn
                beatenConfig.direction = direction
                beatenConfig.element = self.element or nil
                beatenConfig.entity = self._entity
                beatenConfig.attack = self

                e.battle.beatenCaller:Call(self._entity)

                if (self._entity ~= e) then
                    self._entity.attacker.hitCaller:Call(self, e)

                    if (self._entity.identity.superior) then
                        self._entity.identity.superior.attacker.hitCaller:Call(self, e, true)
                    end
                end
                
                if (isCritical) then
                    _NewEffect(_counterEffectData, param)
                    _SOUND.Play(_criticalSoundData)
                end

                if (self.Hit) then
                    self:Hit(e)
                end
                
                do
                    local type

                    if (isPlayer) then
                        type = "player"

                        if (isCritical) then
                            _MAP.camera:Shake(200, -2, 2)
                        end
                    else
                        type = e == _CONFIG.user.player and "beaten" or "other"

                        if (e == _CONFIG.user.player) then
                            type = "beaten"
                            _MAP.camera:Shake(200, -2, 2)
                        else
                            type = "other"
                        end
                    end
                    
                    if (damage > 0) then
                        _WORLD.AddDamageTip(damage, type, x, y + z, isCritical)
                    end
                end

                self._hasAttackedMap[e] = 0
                self._hasAttacked = true

                if (self.isOnce) then
                    break
                end
            end
        end
    end
end

---@param data Actor.RESMGR.AttackData
---@param attackValue Actor.Gear.Attack.AttackValue
---@param Hit function @can null
---@param Collide function @can null
---@param noCollision boolean @default=false
function _Attack:Enter(data, attackValue, Hit, Collide, noCollision)
    _Gear.Enter(self)

    self:Reload()

    if (attackValue and #attackValue > 0) then
        attackValue = attackValue[1]
    end

    self.damage = attackValue and attackValue.damage or data.damage

    if (attackValue and attackValue.isCritical ~= nil) then
        self.isCritical = attackValue.isCritical
    else
        self.isCritical = data.isCritical
    end

    if (attackValue and attackValue.isPhysical ~= nil) then
        self.isPhysical = attackValue.isPhysical
    else
        self.isPhysical = data.isPhysical
    end

    if (attackValue and attackValue.noDef ~= nil) then
        self.noDef = attackValue.noDef
    else
        self.noDef = data.noDef
    end

    self._attributes = self._entity.attributes or self._entity.identity.superior.attributes

    if (self._attributes) then
        local damageRate = attackValue and attackValue.damageRate or data.damageRate
        damageRate = damageRate or 1

        if (not self.damage and damageRate) then
            local atk = self.isPhysical and self._attributes.phyAtk or self._attributes.magAtk
            self.damage = math.floor(atk * damageRate)
        end
    end

    if (self.damage > 0) then
        local rate = self.isPhysical and self._attributes.phyAtkRate or self._attributes.magAtkRate
        self.damage = math.floor(self.damage * rate) + math.random(0, 1)
    end
    
    self.camp = data.camp

    if (self.camp == nil) then
        if (self._entity.battle) then
            self.camp = self._entity.battle.camp
        else
            self.camp = self._entity.identity.superior.battle.camp
        end
    end

    self.hitstop = data.hitstop
    self.selfstop = data.selfstop
    self.noFlash = data.noFlash or false
    self.noSound = data.noSound or false
    self.direction = data.direction
    self.element = data.element
    self.isView = data.isView or false
    self.isOnce = data.isOnce or false
    self.disableAttack = data.disableAttack or false

    if (data.color) then
        self.color:Set(data.color.red, data.color.green, data.color.blue, data.color.alpha)
    else
        if (self.element) then
            self.color:Set(_elementColorGroup[self.element]:Get())
        else
            self.color:Set(_elementColorGroup.none:Get())
        end
    end

    if (data.shake) then
        _TABLE.Clone(data.shake, self.shake)
        self.shake.time = self.shake.time or data.hitstop
    else
        self.shake.time = nil
    end

    if (data.screenShake) then
        _TABLE.Clone(data.screenShake, self.screenShake)
        self.screenShake.time = self.screenShake.time
    else
        self.screenShake.time = nil
    end

    if (data.overturn) then
        self.overturn = _TABLE.Clone(data.overturn)
    else
        self.overturn.movingTime = nil
    end

    if (data.flight) then
        self.flight = _TABLE.Clone(data.flight)
    else
        self.flight.power_z = nil
    end

    if (data.stun) then
        self.stun = _TABLE.Clone(data.stun, self.stun)
    else
        self.stun.time = nil
    end

    if (#self.effectSet > 0) then
        self.effectSet = {}
    end

    if (data.effectSet) then
        if (#data.effectSet > 0) then
            for n=1, #data.effectSet do
                self.effectSet[n] = data.effectSet[n]
            end
        else
            self.effectSet[#self.effectSet + 1] = data.effectSet
        end
    end

    if (#self.soundDataSet > 0) then
        self.soundDataSet = {}
    end

    if (data.soundDataSet) then
        if (type(data.soundDataSet) == "table") then
            for n=1, #data.soundDataSet do
                self.soundDataSet[n] = data.soundDataSet[n]
            end
        else
            self.soundDataSet[#self.soundDataSet + 1] = data.soundDataSet
        end
    end

    if (#self.buffDataSet > 0) then
        self.buffDataSet = {}
    end

    if (data.buff) then
        if (#data.buff > 0) then
            for n=1, #data.buff do
                self.buffDataSet[n] = data.buff[n]
            end
        else
            self.buffDataSet[#self.buffDataSet + 1] = data.buff
        end
    end

    self.collision = {}
    local collision = data.collision or _defaultCollision

    if (not noCollision) then
        for k, v in pairs(collision) do
            local aspect = _ASPECT.GetPart(self._entity.aspect, k)
            self.collision[aspect] = v
        end
    end

    self.Hit = Hit
    self.Collide = Collide or _Attack.DefaultCollide

    if (data.interval) then
        self.timer:Enter(data.interval)
    else
        self.timer:Exit()
    end
end

function _Attack:Reborn()
    _Gear.Enter(self)
end

function _Attack:Reload()
    _TABLE.Clear(self._hasAttackedMap)
    self._hasAttacked = false
end

---@return boolean
function _Attack:HasAttacked()
    return self._hasAttacked
end

---@return boolean
function _Attack:IsVoid()
    return not self.stun.time and not self.flight.power_z and not self.overturn.movingTime
end

function _Attack:PairAttecked()
    return pairs(self._hasAttackedMap)
end

return _Attack