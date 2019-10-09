--[[
	desc: Background, one of MAP's layer.
	author: Musoucrow
	since: 2018-11-15
	alter: 2018-12-24
]]--

local _GRAPHICS = require("lib.graphics") ---@type Lib.GRAPHICS

local _Sprite = require("graphics.drawable.sprite") ---@type Graphics.Drawable.Sprite

---@class MAP.Background:Graphics.Drawable.Sprite
---@field public rate number
local _Background = require("core.class")(_Sprite)

---@param upperEvent event
---@param rate number
function _Background:Ctor(upperEvent, rate)
    _Sprite.Ctor(self, upperEvent)

    self.rate = rate
end

function _Background:_OnDraw()
    _GRAPHICS.Push()
    _GRAPHICS.Translate(-self._upperEvent.GetShift() * self.rate, 0)
    _Sprite._OnDraw(self)
    _GRAPHICS.Pop()
end

return _Background