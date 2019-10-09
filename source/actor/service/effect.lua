--[[
	desc: EFFECT, a service for effect.
	author: Musoucrow
	since: 2018-5-29
	alter: 2019-6-16
]]--

local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _FACTORY = require("actor.factory")

local _effectData = {
    figure = _RESMGR.GetInstanceData("effect/figure"),
    explosion = _RESMGR.GetInstanceData("effect/hitting/explosion")
}

---@class Actor.Service.Effect
local _EFFECT = {}

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
---@param spriteData Lib.RESOURCE.SpriteData
---@param noPure boolean
---@param blendmode string
---@return Actor.Entity
function _EFFECT.NewFigure(transform, aspect, spriteData, noPure, blendmode)
    if (not spriteData) then
        return
    end

    local pos = transform.position
    local param = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        direction = transform.direction,
        spriteData = spriteData,
        blendmode = blendmode,
        noPure = noPure
    }

    return _FACTORY.New(_effectData.figure, param)
end

return _EFFECT