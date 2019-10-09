--[[
	desc: Particle, Actor's Drawable.
	author: Musoucrow
	since: 2018-6-27
	alter: 2018-8-11
]]--

local _CONFIG = require("config")
local _RESMGR = require("actor.resmgr")

local _Collider = require("actor.collider")
local _Graphics_Particle = require("graphics.drawable.particle")
local _Base = require("actor.drawable.base")

---@class Actor.Drawable.Particle:Actor.Drawable
local _Particle = require("core.class")(_Graphics_Particle, _Base)

function _Particle.HandleData(data)
    if (data.path) then
        data.particleData = _RESMGR.GetParticleData(data.path)
        data.path = nil
    end
end

function _Particle.NewWithConfig(upperEvent, data)
    return _Particle.New(upperEvent, data.particleData, data.hasShadow, data.order)
end

---@param upperEvent event
---@param data Lib.RESOURCE.ParticleData
---@param hasShadow boolean
function _Particle:Ctor(upperEvent, data, hasShadow, order)
	_Base.Ctor(self, upperEvent, hasShadow, "particle", order)
	_Graphics_Particle.Ctor(self, upperEvent, data)
end

---@param data Lib.RESOURCE.ParticleData
---@param isOnly boolean
---@return boolean
function _Particle:Play(data, isOnly)
	if (_Graphics_Particle.Play(self, data, isOnly)) then
		if (data.colliderData) then
			local collider = _Collider.New(data.colliderData)
			self:SetCollider(collider)
		end

		return true
	end

	return false
end

function _Particle:_OnDraw()
	_Graphics_Particle._OnDraw(self)

	if (_CONFIG.debug.collider) then
        self:DrawCollider()
    end
end

return _Particle