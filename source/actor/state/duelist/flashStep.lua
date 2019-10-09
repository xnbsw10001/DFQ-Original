--[[
	desc: FlashStep, a state of duelist.
	author: SkyFvcker
	since: 2018-8-5
	alter: 2019-7-8
]]--

local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _INPUT = require("actor.service.input")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _EFFECT = require("actor.service.effect")
local _BUFF = require("actor.service.buff")

local _Color = require("graphics.drawunit.color")
local _Timer = require( "util.gear.timer")
local _Easemove = require("actor.gear.easemove")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.FlashStep:Actor.State
---@field protected _easemove_x Actor.Gear.Easemove
---@field protected _easemove_y Actor.Gear.Easemove
---@field protected _skill Actor.Skill
---@field protected _effect Actor.Entity
---@field protected _easemoveParams table
---@field protected _process int
---@field protected _timerWight int
---@field protected _timer Util.Gear.Timer
---@field protected _figureTimer Util.Gear.Timer
---@field protected _interval int
local _FlashStep = require("core.class")(_Base)

local _color = _Color.New(99, 126, 180, 255)

function _FlashStep:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._easemoveParams = data.easemove
    self._interval = data.interval

    ---@param entity Actor.Entity
    self._OnGuard = function(entity)
        local attack = entity.battle.beatenConfig.attack
        
        if (attack:IsVoid()) then
            return
        end

        local t = entity.transform
        local param = {
            x = t.position.x,
            y = t.position.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity,
            attackValue = self._skill.attackValues[1]
        }

        
    
        _FACTORY.New(self._actorDataSet.bullet, param)
        param.z = t.position.z - math.floor(entity.aspect.height * 0.5)
        _FACTORY.New(self._actorDataSet.effect, param)
    end
end

function _FlashStep:Init(entity)
    _Base.Init(self, entity)

    self._easemove_x = _Easemove.New(self._entity.transform, self._entity.aspect)
    self._easemove_y = _Easemove.New(self._entity.transform, self._entity.aspect)
    self._timer = _Timer.New()
end

function _FlashStep:NormalUpdate(dt, rate)
    self._easemove_x:Update(rate)
    self._easemove_y:Update(rate)
    self._timer:Update(dt)

    if (not self._easemove_x.isRunning and not self._easemove_y.isRunning and self._process == 0) then
        _STATE.Play(self._entity.states, self._nextState)
    end

    if (not self._timer.isRunning and self._process == 0) then
        self:AddEffect()
        self._timerWight = self._timerWight + 1
        self._timer:Enter(self._interval * self._timerWight)
    end
end

function _FlashStep:Enter(laterState, skill)
    _Base.Enter(self)

    self._process = 0
    self._easemove_x:Exit()
    self._easemove_y:Exit()

    self._skill = skill

    self._timerWight = 1
    self._timer:Enter(self._interval * self._timerWight)

    self:EnterMove()

    _SOUND.Play(self._soundDataSet.voice)
    _SOUND.Play(self._soundDataSet.effect)
    _BUFF.AddBuff(self._entity, self._buffDatas)

    local t = self._entity.transform
    local data = self._frameaniDataSets.guard.body ---@type Lib.RESOURCE.FrameaniData
    local param = {
        x = t.position.x,
        y = t.position.y,
        z = t.position.z,
        direction = t.direction,
        entity = self._entity,
        camp = self._entity.battle.camp,
        spriteData = data.list[1].spriteData
    }

    local figure = _FACTORY.New(self._actorDataSet.article, param)
    figure.aspect.color:Set(_Color.blue:Get())
    figure.aspect.colorTick = true
    figure.battle.beatenCaller:AddListener(figure, self._OnGuard)
end

function _FlashStep:EnterMove()
    local direction = self._entity.transform.direction
    local directionX = direction
    local directionY = 0
    local arrowDirection = _INPUT.GetArrowDirection(self._entity.input, directionX)

    if (_INPUT.IsHold(self._entity.input, "down")) then
        directionY = 1
    elseif (_INPUT.IsHold(self._entity.input, "up")) then
        directionY = -1
    end

    --press no keys
    if (arrowDirection == -1 or (arrowDirection == 0 and directionY == 0)) then
        directionX = -directionX
    elseif (arrowDirection == 0 and directionY ~= 0) then
        directionX = 0
    end

    local key
    local keyX
    local keyY

    if (directionX ~= 0) then
        keyX = directionX == direction and "front" or "back"
    end

    if (directionY ~= 0) then
        keyY = directionY == 1 and "down" or "up"
    end

    if (keyX and keyY) then
        key = keyX .. "_" .. keyY
    else
        key = keyX or keyY
    end

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[key])

    local easemoveParam = self._easemoveParams.x
    self._easemove_x:Enter("x", easemoveParam.power, easemoveParam.speed, directionX)

    local easemoveParam = self._easemoveParams.y
    self._easemove_y:Enter("y", easemoveParam.power, easemoveParam.speed, directionY)
end

function _FlashStep:AddEffect()
    local data = _ASPECT.GetPart(self._entity.aspect):GetData()
    local effect = _EFFECT.NewFigure(self._entity.transform, self._entity.aspect, data)
    effect.aspect.order = -1
    effect.aspect.color:Set(_Color.blue:Get())
    effect.aspect.colorTick = true
end

return _FlashStep

