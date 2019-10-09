--[[
	desc: Trigger, a component for collider.
	author: Musoucrow
    since: 2019-6-26
]]--

local _RESMGR = require("actor.resmgr")

local _Collider = require("actor.collider")
local _Caller = require("core.caller")

---@class Actor.Component.Trigger
---@field camp int @nil=player, 0=all, rather than 0=specific camp.
---@field caller Core.Caller
---@field mode string
---@field collider Actor.Collider
local _Trigger = require("core.class")()

function _Trigger.HandleData(data)
    if (data.collider) then
        data.collider = _RESMGR.GetColliderData(data.collider)
    end
end

function _Trigger:Ctor(data, param)
    self.camp = param.camp or data.camp or 0
    self.caller = _Caller.New()
    self.mode = data.mode

    if (data.collider) then
        self.collider = _Collider.New(data.collider)
    end
end

return _Trigger