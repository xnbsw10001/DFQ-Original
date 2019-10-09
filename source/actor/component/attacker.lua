--[[
	desc: Attacker, a component for about attack business.
	author: Musoucrow
	since: 2018-5-8
	alter: 2018-10-1
]]--

local _Caller = require("core.caller")
local _Timer = require("util.gear.timer")

---@class Actor.Component.Attacker
---@field public hitstopTimer Util.Gear.Timer
---@field public hitCaller Core.Caller
---@field public enable boolean
local _Attacker = require("core.class")()

function _Attacker:Ctor()
    self.hitstopTimer = _Timer.New()
	self.hitCaller = _Caller.New()
	self.enable = true
end

return _Attacker