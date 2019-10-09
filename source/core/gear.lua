--[[
	desc: Gear, a repeated component in GearMgr (or not), be responsible for business logic.
	author: Musoucrow
	since: 2018-3-7
	alter: 2018-7-4
]]--

---@class Core.Gear
---@field public isRunning boolean
local _Gear = require("core.class")()

function _Gear:Ctor()
	self.isRunning = false
end

function _Gear:Update()
end

function _Gear:Enter()
	self.isRunning = true
end

function _Gear:Exit()
	self.isRunning = false
end

return _Gear