--[[
	desc: Particle, a Drawable of ParticleSystem.
	author: Musoucrow
	since: 2018-5-08
	alter: 2018-6-20
]]--

local _RESOURCE = require("lib.resource")

local _Base = require("graphics.drawable.base")
local _IPath = require("graphics.drawable.iPath")

local _emptyData = {
    drawing = {
        position = {0, 0},
        scale = {1, 1},
        orientation = 0,
        origin = {0, 0},
        shearing = {0, 0},
        color = {255, 255, 255, 255},
        blendmode = {
            normal = "alpha"
        }
    }
}

---@class Graphics.Drawable.Particle:Graphics.Drawable
---@field public isPaused boolean
---@field protected _drawableObj ParticleSystem
---@field protected _data Lib.RESOURCE.ParticleData
---@field public rate number
local _Particle = require("core.class")(_Base, _IPath)

---@param upperEvent event
---@param data Lib.RESOURCE.ParticleData
function _Particle:Ctor(upperEvent, data)
	_Base.Ctor(self, upperEvent)
	_IPath.Ctor(self)
	
	self:Play(data) --Init self._drawableObj, self._data.
	self.isPaused = false
    self.isActive = false
end

---@param dt number
function _Particle:Update(dt)
	if (not self.isPaused and self._drawableObj) then
        self.isActive = self._drawableObj:isActive()
		self._drawableObj:update((dt * self.rate) * 0.001)
	end
end

---@param data Lib.RESOURCE.ParticleData
---@param isOnly boolean
---@return boolean
function _Particle:Play(data, isOnly)
	if (not data) then
		self._drawableObj = nil
		return true
	elseif (self._data == data) then
		if (not isOnly) then
			return false
		end

		self:Reset()
		return true
	end

    data = data or _emptyData
	self._data = data
	self._path = data.path
	--self._drawableObj = data == _emptyData and nil or _RESOURCE.NewParticleSystemByData(data)
    self._drawableObj = _RESOURCE.NewParticleSystemByData(data)
    self.rate = data.playingSpeed or 1
    self.isActive = true

    self:SetAttri("position", unpack(data.drawing.position))
    self:SetAttri("scale", unpack(data.drawing.scale))
    self:SetAttri("radian", data.drawing.orientation)
    self:SetAttri("origin", unpack(data.drawing.origin))
    self:SetAttri("shear", unpack(data.drawing.shearing))
    self:SetAttri("color", unpack(data.drawing.color))
    self:SetAttri("blendmode", data.drawing.blendmode.normal)

	return true
end

function _Particle:Reset()
	self._drawableObj:reset()
	self._drawableObj:start()
end

function _Particle:TickEnd()
    return self._drawableObj:isActive() == false and self._drawableObj:getCount() == 0
end

---@param name string
function _Particle:RunEvent(name, ...)
	return self._drawableObj[name](self._drawableObj, ...)
end

function _Particle:_OnDraw()
	self._renderer:DrawObj(self._drawableObj)
end

return _Particle