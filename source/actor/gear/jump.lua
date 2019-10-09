--[[
	desc: Jump, a gear for jump business.
	author: Musoucrow
	since: 2018-11-13
]]--

local _Gear = require("core.gear")
local _Easemove = require("actor.gear.easemove")

---@class Actor.Gear.Jump : Core.Gear
---@field protected _transform Actor.Component.Transform
---@field protected _process int
---@field protected _easemove Actor.Gear.Easemove
---@field protected _Func function
---@field protected _downSpeed number
---@field protected _topZ int
local _Jump = require("core.class")(_Gear)

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
function _Jump:Ctor(transform, aspect, Func)
    _Gear.Ctor(self)

    self._transform = transform
    self._easemove = _Easemove.New(transform, aspect)
    self._Func = Func
end

function _Jump:Update(rate)
    if (not self.isRunning) then
        return
    end

    self._easemove:Update(rate)

    if (self._process == 1 and not self._easemove.isRunning) then
        self._process = 2
        self._topZ = self._transform.position.z
        self._easemove:Enter("z", 0, -self._downSpeed, 1)
        self:_Func(2)
    elseif (self._process == 2 and self._transform.position.z > 0) then
        self._process = 3
        self._transform.position.z = 0
        self._transform.positionTick = true
        self:_Func(3)
        self:Exit()
    end
end

---@param upPower number
---@param upSpeed number
---@param downSpeed number
---@param Func function
function _Jump:Enter(upPower, upSpeed, downSpeed)
    _Gear.Enter(self)

    self._easemove:Enter("z", upPower, upSpeed, -1)
    self._downSpeed = downSpeed
    self._process = 1
    self._topZ = self._transform.position.z
    self:_Func(1)
end

---@return int
function _Jump:GetProcess()
    return self._process
end

---@return number
function _Jump:GetPower()
    return self._easemove:GetPower()
end

---@return number
function _Jump:GetZRate()
    return self._transform.position.z / self._topZ
end

return _Jump