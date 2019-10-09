--[[
	desc: WatchValue, a value what can be watching.
	author: Musoucrow
	since: 2018-7-9
]]--

local _Caller = require("core.caller")

---@class Core.WatchValue
---@field protected _caller Core.Caller
---@field protected _value any
local _WatchValue = require("core.class")()

function _WatchValue:Ctor(value)
    self._value = value
    self._caller = _Caller.New()
end

function _WatchValue:Set(value, noCall)
    self._value = value
    
    if (not noCall) then
        self._caller:Call(value)
    end
end

function _WatchValue:Get()
    return self._value
end

function _WatchValue:AddListener(obj, Func)
    self._caller:AddListener(obj, Func)

    if (obj) then
        Func(obj, self._value)
    else
        Func(self._value)
    end
end

function _WatchValue:DelListener(...)
    self._caller:DelListener(...)
end

return _WatchValue