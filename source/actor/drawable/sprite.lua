--[[
	desc: Sprite, Actor's Drawable.
	author: Musoucrow
	since: 2018-6-27
	alter: 2018-8-11
]]--

local _CONFIG = require("config")
local _RESMGR = require("actor.resmgr")

local _Collider = require("actor.collider")
local _Graphics_Sprite = require("graphics.drawable.sprite")
local _Base = require("actor.drawable.base")

---@class Actor.Drawable.Sprite : Graphics.Drawable.Sprite
local _Sprite = require("core.class")(_Graphics_Sprite, _Base)

function _Sprite.HandleData(data)
    if (data.path) then
        data.spriteData = _RESMGR.GetSpriteData(data.path)
        data.path = nil
    end
end

function _Sprite.NewWithConfig(upperEvent, data)
    return _Sprite.New(upperEvent, data.spriteData, data.hasShadow, data.order)
end

---@param upperEvent event
---@param data Lib.RESOURCE.SpriteData
---@param hasShadow boolean
function _Sprite:Ctor(upperEvent, data, hasShadow, order)
	_Base.Ctor(self, upperEvent, hasShadow, "sprite", order)
	_Graphics_Sprite.Ctor(self, upperEvent, data)
end

function _Sprite:SetData(data)
    _Graphics_Sprite.SetData(self, data)

    if (data.colliderData) then
        self:SetCollider(_Collider.New(data.colliderData))
    end
end

function _Sprite:_OnDraw()
    _Graphics_Sprite._OnDraw(self)

    if (_CONFIG.debug.collider) then
        self:DrawCollider()
    end
end

return _Sprite