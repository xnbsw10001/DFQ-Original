--[[
	desc: Camera, A screen controler.
	author: Musoucrow
	since: 2018-6-4
	alter: 2019-8-8
]]--

local _GRAPHICS = require("lib.graphics")
local _SYSTEM = require("lib.system")
local _MATH = require("lib.math")

local _Rect = require("graphics.drawunit.rect")
local _Point = require("graphics.drawunit.point")
local _Radian = require("graphics.drawunit.radian")

---@param sx number
---@param sy number
---@param wdiv number
---@param hdiv number
---@return number @w & h
local function _GetVisibleArea(self, sx, sy, wdiv, hdiv)
	local sin = math.abs(self._sin)
	local cos = math.abs(self._cos)
	local _, _, screen_w, screen_h = self._screen:Get()
	local _, _, world_w, world_h = self._world:Get()
	
	local w = screen_w / sx
	local h = screen_h / sy

	--For fix display scope on unneat resolution, use math.ceil.
	w = math.ceil(cos * w + sin * h)
	h = math.ceil(sin * w + cos * h)
	
	return math.min(w, world_w) / wdiv, math.min(h, world_h) / hdiv
end

---@class Graphics.Camera
---@field protected _position Graphics.Drawunit.Point
---@field protected _translation Graphics.Drawunit.Point
---@field protected _scale Graphics.Drawunit.Point
---@field protected _radian Graphics.Drawunit.Radian
---@field protected _shift Graphics.Drawunit.Point
---@field protected _sin number
---@field protected _cos number
---@field protected _screen Graphics.Drawunit.Rect
---@field protected _world Graphics.Drawunit.Rect
---@field protected _canScale boolean
---@field protected _canRotate boolean
---@field protected _canvas Canvas
---@field protected _shader Shader
local _Camera = require("core.class")()

function _Camera:Ctor()
	local sw, sh = _SYSTEM.GetScreenDimensions()
	
	self._position = _Point.New(true)
	self._translation = _Point.New(true)
	self._scale = _Point.New(false, 1, 1)
	self._shift = _Point.New(true)
	self._radian = _Radian.New()
	self._sin = math.sin (0)
	self._cos = math.cos (0)
	self._screen = _Rect.New(0, 0, sw, sh)
	self._world = _Rect.New(0, 0, 0, 0)
	self._canScale = false
	self._canRotate = false

	self:Adjust()
end

---@param x int
---@param y int
---@param w int
---@param h int
function _Camera:SetWorld(x, y, w, h)
	self._world:Set (x, y, w, h)
	self:Adjust()
end

---@param x int
---@param y int
---@param w int
---@param h int
---@param cx int
---@param cy int
function _Camera:SetScreen(x, y, w, h, cx, cy)
	self._screen:Set(x, y, w, h, 0, cx, cy)
	self:Adjust()
end

---@param x int
---@param y int
function _Camera:SetPosition(x, y)
	self._position:Set(x, y)
	self:Adjust()
end

---@param x number
---@param y number
function _Camera:SetScale(x, y)
	self._scale:Set(x, y)
	self._canScale = x ~= 1 or y ~= 1
	self:Adjust()
end

---@param angle int
function _Camera:SetAngle(angle)
	self._radian:Set(angle, true)
	self._cos = math.cos(self._radian.value)
	self._sin = math.sin(self._radian.value)
	self._canRotate = not self._radian:IsRaw()
	self:Adjust()
end

function _Camera:GetPosition()
	return self._position:Get()
end

function _Camera:GetScale()
	return self._scale:Get()
end

function _Camera:GetShift()
	return self._shift:Get()
end

function _Camera:Apply()
	if (self._canvas) then
		_GRAPHICS.SetCanvas(self._canvas)
		_GRAPHICS.Clear()
	end

	_GRAPHICS.Push()
	
	if (self._canScale) then
		_GRAPHICS.Scale(self._scale:Get())
	end
	
	_GRAPHICS.Translate(self._translation:Get())
	
	if (self._canRotate) then
		_GRAPHICS.Rotate(-self._radian:Get())
	end
	
	local px, py = self._position:Get()
	_GRAPHICS.Translate(-px, -py)
end

function _Camera:Reset()
	_GRAPHICS.Pop()

	if (self._canvas) then
		_GRAPHICS.SetCanvas()
		_GRAPHICS.SetColor(255, 255, 255, 255)
		_GRAPHICS.SetShader(self._shader)
		_GRAPHICS.DrawObj(self._canvas)
		_GRAPHICS.SetShader()
	end
end

function _Camera:Adjust()
	local sx, sy = self._scale:Get()
	local w, h = _GetVisibleArea(self, sx, sy, 2, 2)
	local world_x, world_y, _, _, _, _, _, world_xw, world_yh = self._world:Get()

	local left = world_x + w
	local right = world_xw - w
	local top = world_y + h
	local bottom = world_yh - h

	local px, py = self._position:Get()
	self._position:Set(_MATH.Clamp(px, left, right), _MATH.Clamp(py, top, bottom))

	local screen_x, screen_y, screen_w, screen_h, _, screen_cx, screen_cy = self._screen:Get()
	self._translation:Set((screen_cx + screen_x) / sx, (screen_cy + screen_y) / sy)

	px, py = self._position:Get()
	local tx, ty = self._translation:Get()
	self._shift:Set(tx - px, ty - py)

	if (self._canvas and (self._canvas:getWidth() ~= screen_w or self._canvas:getHeight() ~= screen_h)) then
		self._canvas = _GRAPHICS.NewCanvas(screen_w, screen_h)
	end
end

---@param shader Shader
function _Camera:SetShader(shader)
	self._shader = shader

	if (self._shader) then
		self._canvas = _GRAPHICS.NewCanvas(self._screen:Get("w"), self._screen:Get("h"))
	else
		self._canvas = nil
	end
end

return _Camera