--[[
	desc: Input, a component with key map.
	author: Musoucrow
	since: 2018-3-29
	alter: 2018-5-5
]]--

---@class Actor.Component.Input
local _Input = require("core.class")()

function _Input:Ctor()
    self.map = {}
end

return _Input