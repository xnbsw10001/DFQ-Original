--[[
	desc: Layer, Actor's layer.
	author: Musoucrow
	since: 2018-5-22
]]--

local _Graphics_Layer = require("graphics.drawable.layer")

---@class Actor.Drawable.Layer : Graphics.Drawable.Layer
---@field public z int
local _Layer = require("core.class")(_Graphics_Layer)

function _Layer:Ctor(...)
    _Graphics_Layer.Ctor(self, ...)

    self.z = 0
    self._event.GetZ = function()
        return self.z
    end
end

return _Layer