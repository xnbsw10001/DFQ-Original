--[[
	desc: ActiveObj, for can be destroyed object to use.
	author: Musoucrow
	since: 2018-3-7
	alter: 2018-5-21
]]--

---@class Core.ActiveObj
---@field protected _isDestroyed boolean
---@field protected _upperEvent event
---@field protected _destructionEventName string
local _ActiveObj = require("core.class")()

---@param upperEvent event
---@param destructionEventName string
function _ActiveObj:Ctor(upperEvent, destructionEventName)
	self._isDestroyed = false
	self._upperEvent = upperEvent
	self._destructionEventName = destructionEventName
end

---@return bool
function _ActiveObj:HasDestroyed()
	return self._isDestroyed
end

function _ActiveObj:Destroy(...)
	self._isDestroyed = true
	
	if (self._upperEvent and self._destructionEventName) then
		self._upperEvent[self._destructionEventName](...)
	end
end

return _ActiveObj