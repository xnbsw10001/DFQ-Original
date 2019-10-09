--[[
	desc: Caller, a realization of observer pattern.
	author: Musoucrow
	since: 2018-3-7
	alter: 2018-12-4
]]--

---@class Core.Caller
---@field protected _listenerList list
local _Caller = require("core.class")()

function _Caller:Ctor()
	self._listenerList = {}
end

---@param obj table
---@param Func function
function _Caller:AddListener(obj, Func)
	assert(Func, "Function is null.")
	self._listenerList[#self._listenerList + 1] = {obj = obj, Func = Func}
end

---@param obj table
---@param Func function
---@return bool @Whether successful.
function _Caller:DelListener(obj, Func)
	for n=#self._listenerList, 1, -1 do
		if (self._listenerList[n].obj == obj and self._listenerList[n].Func == Func) then
			table.remove(self._listenerList, n)

			return true
		end
	end

	return false
end

function _Caller:Call(...)
	for n=#self._listenerList, 1, -1 do
		if (not self._listenerList[n].obj) then
			self._listenerList[n].Func(...)
		elseif (self._listenerList[n].obj.HasDestroyed and self._listenerList[n].obj:HasDestroyed()) then
			table.remove(self._listenerList, n)
		else
			self._listenerList[n].Func(self._listenerList[n].obj, ...) --NYI
		end
	end
end

return _Caller