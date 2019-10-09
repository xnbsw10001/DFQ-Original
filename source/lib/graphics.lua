--[[
	desc: GRAPHICS, a lib that encapsulate love.graphics.
	author: Musoucrow
	since: 2018-3-13
	alter: 2018-8-8
]]--

local _TABLE = require("lib.table")
local _MATH = require("lib.math")

local _Tweener = require("util.gear.tweener")

local _nowShader
local _nowBlendmode = "alpha"
local _laterBlendmode
local _nowColor = {255, 255, 255, 255}
local _lateColor = {255, 255, 255, 255}
local _nowFont = love.graphics.getFont()
local _laterFont

local _GRAPHICS = {} ---@class Lib.GRAPHICS
_GRAPHICS.DrawObj = love.graphics.draw
_GRAPHICS.Print = love.graphics.print
_GRAPHICS.SetScissor = love.graphics.setScissor
_GRAPHICS.DrawLine = love.graphics.line
_GRAPHICS.Push = love.graphics.push
_GRAPHICS.Pop = love.graphics.pop
_GRAPHICS.Scale = love.graphics.scale
_GRAPHICS.Translate = love.graphics.translate
_GRAPHICS.Rotate = love.graphics.rotate
_GRAPHICS.Stencil = love.graphics.stencil
_GRAPHICS.SetStencilTest = love.graphics.setStencilTest
_GRAPHICS.SetLineWidth = love.graphics.setLineWidth
_GRAPHICS.GetLineWidth = love.graphics.getLineWidth
_GRAPHICS.NewCanvas = love.graphics.newCanvas
_GRAPHICS.SetCanvas = love.graphics.setCanvas
_GRAPHICS.Clear = love.graphics.clear

function _GRAPHICS.Init()
	love.graphics.setBackgroundColor(0, 0, 0, 255)
end

---@param shader Shader
function _GRAPHICS.SetShader(shader)
	if (_nowShader ~= shader) then
		love.graphics.setShader(shader)
		_nowShader = shader
	end
end

---@param blendmode Blendmode @alpha, add, subtract, multiply, replace, screen
function _GRAPHICS.SetBlendmode(blendmode)
	if (_nowBlendmode ~= blendmode) then
		love.graphics.setBlendMode(blendmode)
        _laterBlendmode = _nowBlendmode
		_nowBlendmode = blendmode
	end
end

function _GRAPHICS.ResetBlendmode()
    _GRAPHICS.SetBlendmode(_laterBlendmode)
end

---@param red int
---@param green int
---@param blue int
---@param alpha int
function _GRAPHICS.SetColor(red, green, blue, alpha)
	if (_nowColor[1] ~= red or _nowColor[2] ~= green or _nowColor[3] ~= blue or _nowColor[4] ~= alpha) then
		love.graphics.setColor(red, green, blue, alpha)
		
		_TABLE.Paste(_nowColor, _lateColor)
		
		_nowColor[1] = red
		_nowColor[2] = green
		_nowColor[3] = blue
		_nowColor[4] = alpha
	end
end

function _GRAPHICS.ResetColor()
	_GRAPHICS.SetColor(unpack(_lateColor))
end

function _GRAPHICS.GetColor()
    return unpack(_nowColor)
end

---@param font Font
function _GRAPHICS.SetFont(font)
    if (_nowFont ~= font) then
        _laterFont = _nowFont
        _nowFont = font
        love.graphics.setFont(font)
    end
end

function _GRAPHICS.ResetFont()
    _GRAPHICS.SetFont(_laterFont)
end

---@param x int
---@param y int
---@param size number
---@param mode DrawMode @fill, line
function _GRAPHICS.DrawCircle(x, y, size, mode)
	mode = mode or "line"
	
	love.graphics.circle (mode, x, y, size)
end

---@param mode DrawMode @fill, line
function _GRAPHICS.DrawPolygon(mode, ...)
	love.graphics.polygon (mode, ...)
end

---@param x int
---@param y int
---@param w int
---@param h int
---@param mode DrawMode @fill, line
function _GRAPHICS.DrawRect(x, y, w, h, mode)
	mode = mode or "line"
	
	love.graphics.rectangle(mode, x, y, w, h)
end

---@param drawable Graphics.Drawable
function _GRAPHICS.NewDrawableAttriTweener(drawable, subject, type)
    return _Tweener.New(subject, _, _, function()
        drawable:SetAttri(type, subject:Get())
    end)
end

return _GRAPHICS