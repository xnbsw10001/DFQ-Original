--[[
	desc: Onceplay, a mark of once play.
	author: Musoucrow
	since: 2018-5-23
	alter: 2019-3-28
]]--

local _Timer = require("util.gear.timer")

local _emptyTable = {}

---@class Actor.Component.Onceplay
---@field public type string
---@field public objs string|table
---@field public timer Util.Gear.Timer
local _Onceplay = require("core.class")()

function _Onceplay:Ctor(data, param)
    data = data or _emptyTable
    param = param or _emptyTable

    self.type = data.type
    self.objs = data.objs

    local time = data.time or param.onceplay_time

    if (time) then
        self.timer = _Timer.New(time)
    else
        self.type = self.type or "normal"
    end
end

return _Onceplay

