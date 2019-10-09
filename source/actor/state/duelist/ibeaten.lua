--[[
	desc: a basic interface of beaten business.
	author: Musoucrow
	since: 2018-5-28
]]--

---@class Actor.State.Duelist.IBeaten
local _IBeaten = require("core.class")()

function _IBeaten:Update()
    if (self._entity.identity.isPaused ~= self._isBeaten) then
        self._isBeaten = not self._isBeaten
        self:OnBeaten(self._isBeaten)
    end
end

function _IBeaten:Enter()
    self._isBeaten = self._entity.identity.isPaused
    self:OnBeaten(self._isBeaten)
end

-- _IBeaten:OnBeaten(isBeaten)

return _IBeaten