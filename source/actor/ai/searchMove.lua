--[[
	desc: SearchMove, a Ai of search and move.
	author: Musoucrow
	since: 2018-5-14
	alter: 2019-8-15
]]--

local _ECSMGR = require("actor.ecsmgr")
local _BATTLE = require("actor.service.battle")
local _INPUT = require("actor.service.input")
local _STATE = require("actor.service.state")

local _Timer = require("util.gear.timer")
local _Point = require("graphics.drawunit.point")
local _Range = require("graphics.drawunit.range")
local _Move = require("actor.ai.move")
local _Base = require("actor.ai.base")

local _list = _ECSMGR.NewComboList({
    battle = true,
    transform = true
})

---@class Actor.Ai.SearchMove : Actor.Ai
---@field public searchRange Graphics.Drawunit.Range
---@field public moveRange Graphics.Drawunit.Range
---@field public intervalSection Graphics.Drawunit.Point
---@field public lockOn boolean
---@field public campType string
---@field public navigating boolean
---@field public camp int
---@field protected _target Graphics.Drawunit.Point
---@field protected _timer Util.Gear.Timer
---@field protected _moveAi Actor.Ai.Move
---@field protected _hasTarget boolean
local _SearchMove = require("core.class")(_Base)

---@param entity Actor.Entity
function _SearchMove.NewWithConfig(entity, data)
    return _SearchMove.New(entity, data.searchRange, data.moveRange, data.lockOn, data.interval, data.campType, data.camp)
end

---@param entity Actor.Entity
---@param searchRange Graphics.Drawunit.Range
---@param moveRange Graphics.Drawunit.Range
---@param lockOn boolean
---@param intervalSection Graphics.Drawunit.Point
---@param campType string @all, same, enemy, else. default=enemy
function _SearchMove:Ctor(entity, searchRange, moveRange, lockOn, intervalSection, campType, camp)
    _Base.Ctor(self, entity)

    self.searchRange = _Range.New(searchRange.xa, searchRange.xb, searchRange.ya, searchRange.yb)
    self.moveRange = _Range.New(moveRange.xa, moveRange.xb, moveRange.ya, moveRange.yb)
    self.intervalSection = _Point.New(true, intervalSection.x, intervalSection.y)
    self._timer = _Timer.New()
    self._target = _Point.New(true)
    self._moveAi = _Move.New(entity)
    self.lockOn = lockOn
    self.campType = campType or "enemy"
    self.camp = camp
    self._hasTarget = false
    self.navigating = false
end

function _SearchMove:Update(dt)
    if (not self:CanRun()) then
        return
    end
    
    self._timer:Update(dt)

    if (not self.navigating and not self._timer.isRunning) then
        self._timer:Enter(math.random(self.intervalSection.x, self.intervalSection.y))

        local hasTarget, x, y = self:Select()
        self._hasTarget = hasTarget
        self._target:Set(x, y)

        local directionX = math.random(1, 2) == 1 and 1 or -1
        local directionY = math.random(1, 2) == 1 and 1 or -1
        x = x + math.random(self.moveRange.xa, self.moveRange.xb) * directionX
        y = y + math.random(self.moveRange.ya, self.moveRange.yb) * directionY
        
        self._moveAi:Tick(x, y)

        --return true
    end

    self:LockOn()
    self._moveAi:Update(dt)

    if (self.navigating and not self._moveAi:IsRunning()) then
        self.navigating = false
    end
end

function _SearchMove:LockOn()
    if (not self:CanRun() or not self._hasTarget or not self.lockOn) then
        return
    end

    local transform = self._entity.transform
    local direction = transform.position.x < self._target.x and 1 or -1

    if (direction == transform.direction) then
        _INPUT.Press(self._entity.input, "lockOn") -- Press the key to lock direction, see also: actor/controlMove.lua
    end
end

function _SearchMove:Select()
    local camp = self.camp or self._entity.battle.camp
    local x, y = self._entity.transform.position:Get()
    
    if (self.campType ~= "") then
        for n=_list:GetLength(), 1, -1 do
            local e = _list:Get(n) ---@type Actor.Entity
    
            if (e.battle and self._entity ~= e and e.battle.banCountMap.hide == 0 and _BATTLE.CondCamp(camp, e.battle.camp, self.campType)) then
                local pos = e.transform.position
    
                if (self.searchRange:Collide(x, y, pos.x, pos.y)) then
                    return true, pos:Get()
                end
            end
        end
    end

    return false, x, y
end

---@param x int
---@param y int
---@param isOnly boolean
---@param lockOn boolean
function _SearchMove:MoveTo(x, y, isOnly, lockOn)
    self._target:Set(x, y)
    self._moveAi:Tick(x, y)

    if (isOnly) then
        self._timer:Exit()
        self.navigating = true
    end
    
    self._hasTarget = lockOn or false
end

---@return boolean
function _SearchMove:IsMoving()
    return self._moveAi:IsRunning()
end

---@param isReal boolean @moveAi's target
---@return int, int
function _SearchMove:GetTarget(isReal)
    if (isReal) then
        return self._moveAi:GetTarget()
    end

    return self._target:Get()
end

---@return boolean
function _SearchMove:CanRun()
    local free = (self._entity.states and _STATE.HasTag(self._entity.states, "moveable")) or not self._entity.states
    return _Base.CanRun(self) and free
end

function _SearchMove:Reset()
    self.navigating = false
    self._timer:Exit()
end

return _SearchMove