--[[
	desc: Timer, it is a gear.
	author: Musoucrow
	since: 2018-7-7
	alter: 2018-8-8
]]--

local _MATH = require("lib.math") ---@type Lib.MATH

local _Gear = require("core.gear") ---@type Core.Gear

---@class Util.Gear.Timer:Core.Gear
---@field public from number
---@field public to number
local _Timer = require("core.class")(_Gear)

function _Timer:Ctor(time)
	_Gear.Ctor(self)
	
	self.from = 0
	self.to = 0

	if (time) then
		self:Enter(time)
	end
end

---@param dt number
function _Timer:Update(dt)
	if (not self.isRunning) then
		return
	end

	self.from = self.from + dt

	if (self.to > 0 and self.from >= self.to) then
		self.from = self.to
		self:Exit()
	end
end

---@param time number
function _Timer:Enter(time)
	_Gear.Enter(self)

	self.from = 0
	self.to = time or self.to or 0
	
	if (self.from == self.to) then
		self.isRunning = false
	end
end

function _Timer:GetProcess()
	return _MATH.GetFixedDecimal(self.from / self.to)
end

return _Timer