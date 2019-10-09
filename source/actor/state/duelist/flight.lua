--[[
	desc: Flight, a state of Duelist.
	author: Musoucrow
	since: 2018-9-10
	alter: 2019-3-8
]]--

local _MATH = require("lib.math")
local _SOUND = require("lib.sound")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")

local _Easemove = require("actor.gear.easemove")
local _IBeaten = require("actor.state.duelist.ibeaten")
local _Base = require("actor.state.base")

local _processEnum = {up_1 = 1, up_2 = 2, up_3 = 3, down_1 = 4, down_2 = 5}

---@class Actor.State.Duelist.Flight:Actor.State
---@field protected _easemove_x Actor.Gear.Easemove
---@field protected _easemove_z Actor.Gear.Easemove
---@field protected _process int
---@field protected _power_z number
---@field protected _upSpeed number
---@field protected _downSpeed number
---@field protected _tmp number
---@field protected _isLow boolean
---@field protected _isBound boolean
---@field protected _isBeaten boolean
---@field protected _inRotate boolean
---@field protected _flagMap table<string, boolean>
---@field protected _Func function
local _Flight = require("core.class")(_Base, _IBeaten)

function _Flight:Ctor(...)
    _Base.Ctor(self, ...)
end

function _Flight:Init(entity)
    _Base.Init(self, entity)

    self._easemove_x = _Easemove.New(entity.transform, entity.aspect)
    self._easemove_z = _Easemove.New(entity.transform, entity.aspect)
    self._power_z = 0
    self._upSpeed = 0
    self._downSpeed = 0
    self._tmp = 0
    self._process = 0
    self._isLow = false
    self._isBound = false
    self._inRotate = false
end

function _Flight:Update(dt, rate)
    _IBeaten.Update(self)
    _Base.Update(self, dt, rate)
end

function _Flight:NormalUpdate(dt, rate)
    if (self._inRotate and self._flagMap.rotate) then
        local r = self._entity.transform.radian:Get()
        self._entity.transform.radian:Set(r + self._flagMap.rotate)
        self._entity.transform.radianTick = true
    end

    self._easemove_x:Update(rate)
    self._easemove_z:Update(rate)

    if (self._process == _processEnum.up_1 and self._easemove_z:GetPower() <= self._tmp) then
        self._process = _processEnum.up_2
        self._tmp = _MATH.GetFixedDecimal(self._power_z * 0.3)
        self:PlayAnimation()

        if (not self._isLow and self._flagMap.rotate ~= nil) then
            local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
            local ox, oy = main:GetAttri("origin")
            local height = math.floor(main:GetHeight() * 0.5)
            main:SetAttri("origin", ox, oy - height)
            self._inRotate = true
        end
    elseif (self._process == _processEnum.up_2 and self._easemove_z:GetPower() <= self._tmp) then
        self._process = _processEnum.up_3
        self:PlayAnimation()
    elseif (self._process == _processEnum.up_3 and not self._easemove_z.isRunning) then
        self._process = _processEnum.down_1
        self._easemove_z:Enter("z", 0, -self._downSpeed, 1)
        self._tmp = _MATH.GetFixedDecimal(self._entity.transform.position.z * 0.6)
    elseif (self._process == _processEnum.down_1 and self._entity.transform.position.z >= self._tmp) then
        self._process = _processEnum.down_2
        self:ExitRotate()
        self:PlayAnimation()
    elseif (self._process == _processEnum.down_2 and self._entity.transform.position.z > 0) then
        self._entity.transform.position.z = 0
        self._entity.transform.positionTick = true
        _SOUND.Play(self._soundDataSet)

        if (self._isLow) then
            _STATE.Play(self._entity.states, self._nextState)
        else
            self._flagMap.rotate = nil
            self:Enter(self, self._power_z * 0.5, self._upSpeed, self._downSpeed, self._easemove_x:GetPower(), self._easemove_x:GetSpeed(), self._easemove_x.direction, self._flagMap, self._Func)
            self:_Func("rebound")
        end
    end

    self:_Func("update")
end

function _Flight:OnBeaten(isBeaten)
    if (self._isBeaten and self._process == _processEnum.down_1 or self._process == _processEnum.down_2) then
        self._easemove_z:SetPower(0)
    end

    self:ExitRotate()
    self:PlayAnimation()
end

---@param lateState Actor.State
---@param power_z milli
---@param upSpeed milli
---@param downSpeed milli
---@param power_x milli
---@param speed milli
---@param direction direction
---@param flagMap table<string, boolean> @can null
---@param Func function @can null
---@param isBound boolean
function _Flight:Enter(lateState, power_z, upSpeed, downSpeed, power_x, speed, direction, flagMap, Func)
    _Base.Enter(self)

    local rebound = lateState == self and self._entity.transform.position.z == 0

    if (self._entity.duelist and not rebound) then
        power_z = power_z - self._entity.duelist.weight
        power_z = power_z < 0 and 0 or power_z
    end

    local isLow = self._entity.transform.position.z >= -30
    local isFall = lateState:HasTag("fall")

    if (not flagMap.consistent) then
        if (not rebound and isLow and isFall) then
            power_z = power_z * 0.5
            power_x = power_x
        end
    end

    power_z = _MATH.GetFixedDecimal(power_z)
    upSpeed = _MATH.GetFixedDecimal(upSpeed)
    downSpeed = _MATH.GetFixedDecimal(downSpeed)
    power_x = _MATH.GetFixedDecimal(power_x)
    speed = _MATH.GetFixedDecimal(speed)

    self._power_z = power_z
    self._upSpeed = upSpeed
    self._downSpeed = downSpeed
    self._flagMap = flagMap
    self._Func = Func

    self._easemove_x:Enter("x", power_x, speed, direction)
    self._easemove_z:Enter("z", power_z, upSpeed, -1)

    self._tmp = math.floor(self._power_z * 0.65)
    self._process = _processEnum.up_1

    self._isLow = isLow and self._power_z <= 5
    self._isBound = isFall and self._isLow
    self._inRotate = false

    _IBeaten.Enter(self)
    self:_Func("enter")
end

---@param nextState Actor.State
function _Flight:Exit(nextState)
    _Base.Exit(self)
    
    self:ExitRotate()
    self:_Func("exit")
end

function _Flight:PlayAnimation()
    if (self._inRotate) then
        return
    end

    local index = 0
    
    if (self._isBound) then
        if (self._process == _processEnum.up_1 or self._process == _processEnum.up_2) then
            if (self._isBeaten) then
                index = 4
            else
                index = 3
            end
        elseif (self._process == _processEnum.up_3 or self._process == _processEnum.down_1 or self._process == _processEnum.down_2) then
            if (self._isBeaten) then
                index = 3
            else
                index = 4
            end
        end
    else
        if (self._process == _processEnum.up_1) then
            if (self._isBeaten) then
                index = 2
            else
                index = 1
            end
        elseif (self._process == _processEnum.up_2) then
            if (self._isBeaten) then
                index = 1
            else
                index = 2
            end
        else
            if (self._isBeaten) then
                index = 1
            else
                index = 3
            end
        end
    end

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[index])
end

function _Flight:ExitRotate()
    if (self._inRotate) then
        self._entity.transform.radian:Set(0)
        self._entity.transform.radianTick = true
        self._inRotate = false
    end
end

return _Flight