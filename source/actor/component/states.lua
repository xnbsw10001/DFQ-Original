--[[
	desc: States, a component of state set.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-7-29
]]--

local _RESMGR = require("actor.resmgr")

local _Caller = require("core.caller")

---@class Actor.Component.States
---@field public map table<string, Actor.State>
---@field public current Actor.State
---@field public later Actor.State
---@field public caller Core.Caller
---@field public firstState Actor.State
local _States = require("core.class")()

function _States.HandleData(data)
    for k, v in pairs(data) do
        if (k ~= "class") then
            data[k] = _RESMGR.GetStateData(v)
        end
    end
end

function _States:Ctor(data, param)
    self.map = {}
    self.caller = _Caller.New()
    self.firstState = param.firstState or "stay"

    for k, v in pairs(data) do
        if (k ~= "class") then
            self.map[k] = v.class.New(v, param, k)
        end
    end
end

return _States