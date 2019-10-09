--[[
	desc: Transparency, a system of transparency.
	author: Musoucrow
	since: 2018-5-18
	alter: 2018-12-26
]]--

local _CONFIG = require("config")
local _ASPECT = require("actor.service.aspect")
local _MOTION = require("actor.service.motion")

local _SolidRect = require("graphics.drawunit.solidRect")
local _Collider = require("actor.collider")
local _Base = require("actor.system.base")

---@class Actor.System.Transparency : Actor.System
local _Transparency = require("core.class")(_Base)

function _Transparency:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        aspect = true,
        transform = true,
        transparency = true
    }, "transparency")
end

---@param entity Actor.Entity
function _Transparency:OnEnter(entity)
    local main = _ASPECT.GetPart(entity.aspect) ---@type Graphics.Drawable.IRect | Graphics.Drawable
    local w = main:GetWidth()
    local h = main:GetHeight()
    local rate = main:GetAttri("origin") / w
    local t = entity.transparency

    local colliderData = {
        {
            x = -math.floor(w * rate),
            y1 = -math.floor(h * t.rate),
            z = 0,
            y2 = 0,
            w = w,
            h = h
        }
    }

    t.collider = _Collider.New(colliderData)
    t.colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    t.colorTweener:SetTarget({alpha = 0})
end

function _Transparency:LateUpdate(dt)
    if (not _CONFIG.user.player) then
        return
    end

    local a = _ASPECT.GetBodySolidRectList(_CONFIG.user.player.aspect)

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local transparency = e.transparency

        _MOTION.AdjustCollider(e.transform, transparency.collider, _, transparency.y)
        local b = e.transparency.collider:GetList()

        if (_SolidRect.CollideWithList(a, b) ~= transparency.isTransparent) then
            transparency.isTransparent = not transparency.isTransparent
            transparency.colorTweener:GetTarget().alpha = transparency.isTransparent and 127 or 255
            transparency.colorTweener:Enter(transparency.motionTime)
        end

        transparency.colorTweener:Update(dt)
    end
end

if (_CONFIG.debug.transparency) then
    function _Transparency:Draw()

        for n=1, self._list:GetLength() do
            local e = self._list:Get(n) ---@type Actor.Entity
            e.transparency.collider:Draw()
        end
    end
end

return _Transparency