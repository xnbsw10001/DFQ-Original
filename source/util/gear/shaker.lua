--[[
	desc: Shaker, a gear of handling business of shaking.
	author: Musoucrow
	since: 2018-7-7
	alter: 2019-3-28
]]--

local _Timer = require("util.gear.timer")
local _Gear = require("core.gear")

---@class Util.Gear.Shaker:Core.Gear
---@field protected _timer Util.Gear.Timer
---@field public subject table
---@field public config table
---@field public Callback function
local _Shaker = require("core.class")(_Gear)

function _Shaker:Ctor(subject, config, Callback)
	_Gear.Ctor(self)

	self._timer = _Timer.New()
	self.subject = subject
	self.config = config
	self.Callback = Callback
end

---@param dt milli
function _Shaker:Update(dt)
	if (not self.isRunning) then
		return
	end

	self._timer:Update(dt)

	if (self._timer.isRunning) then
		for k, v in pairs(self.config) do
			self.subject[k] = math.random(v[1], v[2])
		end
	else
		self:Exit()
	end

	if (self.Callback) then
		self.Callback(self.subject)
	end
end

---@param time milli
---@param subject table
---@param config table @usage: {key = {min, max, origin(0)}, ...} e.g. {x = {-1, 1, 0}}
---@param Callback function
function _Shaker:Enter(time, config, subject, Callback)
	_Gear.Enter(self)

	self._timer:Enter(time)
	self.subject = subject or self.subject
	self.config = config or self.config
	self.Callback = Callback or self.Callback
end

function _Shaker:Exit()
	_Gear.Exit(self)

	for k, v in pairs(self.config) do
		self.subject[k] = v[3] or 0
	end
end

return _Shaker