--[[
	desc: Figure, a system of figure's business.
	author: Musoucrow
    since: 2018-5-29
    alter: 2018-12-26
]]--

local _RESOURCE = require("lib.resource")
local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

local _shaderData = _RESOURCE.GetShaderData("white")

---@class Actor.System.Effect.Figure : Actor.System
local _Figure = require("core.class")(_Base)

function _Figure:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        effect_figure = true,
        aspect = true,
        identity = true
    }, "effect_figure")
end

---@param entity Actor.Entity
function _Figure:OnEnter(entity)
    local figure = entity.effect_figure ---@type Actor.Component.Effect.Figure

    figure.colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    figure.colorTweener:Enter(figure.time, {alpha = 0})

    local sprite = _ASPECT.GetPart(entity.aspect) ---@type Graphics.Drawable.Sprite
    sprite:SetData(figure.spriteData)
    sprite:SetAttri("blendmode", figure.blendmode)
    
    if (not figure.noPure) then
        sprite:SetAttri("shader", _shaderData)
    end
end

function _Figure:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local colorTweener = e.effect_figure.colorTweener

        colorTweener:Update(dt)

        if (not colorTweener.isRunning) then
            e.identity.destroyProcess = 1
        end
    end
end

return _Figure

