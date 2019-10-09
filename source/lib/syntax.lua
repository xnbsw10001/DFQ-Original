--[[
	desc: SYNTAX, a lib that encapsulate syntax function.
	author: Musoucrow
	since: 2018-4-26
	alter: 2019-8-15
]]--

local _CONFIG = require("config")

local _SYNTAX = {} ---@class Lib.SYNTAX

---@param bool boolean
---@return int
function _SYNTAX.BoolToNum(bool)
	if (bool) then
		return 1
	else
		return 0
	end
end

---@param bool boolean
---@return int
function _SYNTAX.BoolToDirection(bool)
	if (bool) then
		return 1
	else
		return -1
	end
end

return _SYNTAX