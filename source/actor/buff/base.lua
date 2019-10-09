--[[
	desc: Buff, A business for some time.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-9-20
]]--

local _TABLE = require("lib.table")
local _WORLD = require("actor.world")
local _BUFF = require("actor.service.buff")

local _Timer = require("util.gear.timer")

---@class Actor.Buff
---@field protected _entity Actor.Entity
---@field protected _data Actor.RESMGR.BuffData
---@field protected _timer Util.Gear.Timer
---@field protected _hasExited boolean
local _Buff = require("core.class")()

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Buff.CanNew(entity, data)
    if (data.isDebuff and entity.buffs.undebuffCount > 0) then
        return false
    elseif (data.isOnly or data.tag) then
        local buff = _BUFF.GetBuff(entity.buffs, data.path, data.tag)

        if (buff) then
            if (data.tag) then
                buff:SetTime(data.time)
            end

            return false
        end
    end

    return true
end

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
function _Buff:Ctor(entity, data)
    self._entity = entity
    self._data = data
    self._hasExited = false

    local time = data.time or -1
    self._timer = _Timer.New(time)
end

function _Buff:Update(dt)
    if (not self:IsRunning()) then
        return
    end

    self:OnUpdate(dt)
end

function _Buff:LateUpdate(dt)
    if (not self:IsRunning()) then
        return
    end

    self:OnLateUpdate(dt)

    self._timer:Update(dt)

    if (not self._timer.isRunning) then
        self:Exit()
    end
end

function _Buff:OnUpdate(dt)
end

function _Buff:OnLateUpdate(dt)
end

---@return boolean
function _Buff:Exit()
    if (self._hasExited) then
        return false
    end

    self._timer:Exit()
    self._hasExited = true
    self._entity.buffs.delCaller:Call(self)

    return true
end

---@return Actor.RESMGR.BuffData
function _Buff:GetData()
    return self._data
end

---@return Actor.RESMGR.BuffData
function _Buff:ToData()
    if (not self:IsRunning()) then
        return nil
    end

    local data = {time = self._timer.to - self._timer.from}
    setmetatable(data, {__index = _TABLE.GetOrigin(self._data, true)})

    return data
end

---@return string
function _Buff:GetPath()
    return self._data.path
end

---@return boolean
function _Buff:IsOnly()
    return self._data.isOnly or false
end

---@return boolean
function _Buff:IsRunning()
    return self._timer.isRunning and not self._hasExited
end

---@return number
function _Buff:GetProcess()
    return self._timer:GetProcess()
end

---@param time milli
function _Buff:SetTime(time)
    self._timer:Enter(time)
end

return _Buff