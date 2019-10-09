--[[
	desc: MockTweener, a mock tweener.
	author: Musoucrow
	since: 2018-4-19
]]--

local _Tweener = require("util.gear.tweener")

---@class Util.Gear.MockTweener : Util.Gear.Tweener
---@field protected _keys table<number, string>
---@field public initial table
---@field public target table
---@field public later table
local _MockTweener = require("core.class")(_Tweener)

function _MockTweener:Ctor(keys, easing, Callback)
    _Tweener.Ctor(self, _, _, easing, Callback)

    self._keys = keys
    self.initial = {}
    self.target = {}
    self.later = {}
end

function _MockTweener:Update(dt)
    _Tweener.Update(self, dt)

    if (self.isRunning) then
        for n=1, #self._keys do
            local k = self._keys[n]
            self.later[k] = self._tween.subject[k]
        end
    end
end

---@param time milli
---@param initial table
---@param target table
---@param easing string
---@param Callback function
function _MockTweener:Enter(time, initial, target, easing, Callback)
    for n=1, #self._keys do
        local k = self._keys[n]

        if (initial) then
            self.initial[k] = initial[k]
        end

        if (target) then
            self.target[k] = target[k]
        end

        self.later[k] = self.initial[k]
    end

    _Tweener.Enter(self, time, self.target, easing, self.initial, Callback)
end

return _MockTweener