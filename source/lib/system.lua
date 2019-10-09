--[[
	desc: SYSTEM, a lib that encapsulate system and window function.
	author: Musoucrow
	since: 2018-5-27
	alter: 2019-10-8
]]--

local _CONFIG = require("config")
local _FILE = require("lib.file")
local _TABLE = require("lib.table")

local _os = love.system.getOS()
local _stdWidth = 960
local _stdHeight = 540
local _width, _height = love.graphics.getDimensions()

local _realWidth, _realHeight = _width, _height
local _screenDiv = {x = 0, y = 0}

do
	if ((_height / 9) ~= math.floor(_height / 9)) then
		local height = math.floor(_width / 16 * 9)
		_screenDiv.y = math.floor((_height - height) * 0.5)
		_height = height
	else
		local width = math.floor((_height / 9) * 16)
		_screenDiv.x = math.floor((_width - width) * 0.5)
		_width = width
	end
end

local _sx, _sy = _width / _stdWidth, _height / _stdHeight

local _SYSTEM = {} ---@class Lib.SYSTEM

---@return string @OS X, Windows, Linux, Android, iOS
function _SYSTEM.GetOS()
	return _os
end

---@return bool
function _SYSTEM.IsMobile()
	return false
end

---@param isReal boolean
---@return int @w & h
function _SYSTEM.GetScreenDimensions(notReal)
	if (notReal) then
		return _width, _height
	else
		return _realWidth, _realHeight
	end
end

---@return int @w & h
function _SYSTEM.GetStdDimensions()
	return _stdWidth, _stdHeight
end

---@return int @w & h
function _SYSTEM.GetUIStdDimensions()
	return 1280, 720
end

---@param w int
---@param h int
function _SYSTEM.OnResize(w, h)
	_width = w
	_height = h
	_sx = _width / 960
	_sy = _height / 540
end

function _SYSTEM.Collect()
	collectgarbage("collect")
end

---@return number, number
function _SYSTEM.GetScale()
	return _sx, _sy
end

---@return int, int
function _SYSTEM.GetScreenDiv()
	return _screenDiv.x, _screenDiv.y
end

return _SYSTEM