--[[
	desc: Ai, a util for Ai.
	author: Musoucrow
	since: 2018-5-5
	alter: 2018-8-7
]]--

---@class Actor.Ai
---@field protected _entity Actor.Entity
---@field public Tick function
---@field public enable boolean
---@field public login boolean
local _Ai = require("core.class")()

---@param entity Actor.Entity
function _Ai:Ctor(entity)
    self._entity = entity
    self.enable = true
    self.login = false
end

function _Ai:CanRun()
    return self.enable and self._entity.ais.enable
end

---_Ai:Tick()

return _Ai