--[[
	desc: Label, a Drawable of Font.
	author: Musoucrow
	since: 2018-4-27
	alter: 2019-8-27
]]--

local _RESOURCE = require("lib.resource")

local _Base = require("graphics.drawable.base")
local _IRect = require("graphics.drawable.iRect")
local _IPath = require("graphics.drawable.iPath")

---@class Graphics.Drawable.Label:Graphics.Drawable
---@field protected _drawableObj Text
---@field protected _data Lib.RESOURCE.FontData
---@field protected _content string
---@field protected _font Font
---@field protected _align string
local _Label = require("core.class")(_Base, _IRect, _IPath)

---@param upperEvent event
---@param data Lib.RESOURCE.FontData
---@param content string
---@param rectEnabled boolean
---@param align string @nil(left), right, middle
function _Label:Ctor(upperEvent, data, content, rectEnabled, align)
	_Base.Ctor(self, upperEvent)
	_IRect.Ctor(self, rectEnabled)
	_IPath.Ctor(self)

	self._drawableObj = _RESOURCE.NewText()
	self._align = align
    self:SetData(data)
	self:SetContent(content)
end

function _Label:SetAttri(type, ...)
	if (type == "origin" and self._data.base ~= 0) then
		local arg = {...}
		arg[2] = arg[2] + self._data.base

		_Base.SetAttri(self, type, unpack(arg))
	else
		_Base.SetAttri(self, type, ...)
	end
end

---@param data Lib.RESOURCE.FontData
---@return boolean
function _Label:SetData(data)
	if (self._data == data) then
		return false
	end

	self._data = data
	self:SetFont(data.font, data.path)

	return true
end

---@param font Font
---@param path string
function _Label:SetFont(font, path)
	self._drawableObj:setFont(font)
	self._path = path or ""
	self._font = font

	if (self._content) then
		self:AdjustAlign()
	end
end

---@return Font
function _Label:GetFont()
    return self._font
end

function _Label:SetContent(content)
	if (self._content == content) then
		return
	end

    content = content or ""

	self._drawableObj:set(content)

	if (type(content) == "table") then
		local stringBuffer = {}

        for n=2, #content, 2 do
            table.insert(stringBuffer, content[n])
        end

        self._content = table.concat(stringBuffer)
    else
        self._content = content
	end
	
	self:AdjustAlign()
end

function _Label:GetContent()
    return self._content
end

---@param align string
function _Label:SetAlign(align)
	if (self._align == align) then
		return
	end

	self._align = align
	self:AdjustAlign()
end

---@return string
function _Label:GetAlign()
	return self._align
end

function _Label:AdjustAlign()
	if (self._align == "right") then
		_Base.SetAttri(self, "origin", self._drawableObj:getWidth(), self._data.base)
	elseif (self._align == "middle") then
		_Base.SetAttri(self, "origin", math.floor(self._drawableObj:getWidth() * 0.5), self._data.base)
	else
		_Base.SetAttri(self, "origin", 0, self._data.base)		
	end

	self:AdjustDimensions()
end

function _Label:AdjustDimensions(notAdjustRect)
	self._width = self._drawableObj:getWidth()
	self._height = self._drawableObj:getHeight()
	
	if (not notAdjustRect) then
		self:AdjustRect()
	end
end

function _Label:_OnDraw()
	self._renderer:DrawObj(self._drawableObj)
end

return _Label