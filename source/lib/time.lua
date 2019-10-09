--[[
	desc: TIME, a lib that encapsulate time function.
	author: Musoucrow
	since: 2018-5-8
	alter: 2018-12-17
]]--

local _delta = 0
local _time = 0
local _fps = 0
local _stddt = 17
local _updateTime = 0
local _frame = 0
local _calmness = false

local _TIME = {} ---@class Lib.TIME

---@return number
function _TIME.GetDelta()
	return _stddt
end

---@return number
function _TIME.GetTime()
	return _time
end

---@return number
function _TIME.GetFPS()
	return _fps
end

---@return int
function _TIME.GetFrame()
	return _frame
end

function _TIME.Calmness()
	_calmness = true
end

function _TIME.CanUpdate()
	return _updateTime >= _stddt
end

---@param dt number
function _TIME.Update(dt)
	if (_calmness) then
		_calmness = false
		_delta = 0
	else
		_delta = math.floor(dt * 1000)
	end
	
	_time = love.timer.getTime()
	_fps = love.timer.getFPS()
	_updateTime = _updateTime + _delta
end

function _TIME.LateUpdate()
	_updateTime = _updateTime - _stddt
end

function _TIME.FrameUpdate()
	_frame = _frame + 1
end

return _TIME