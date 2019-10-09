--[[
	desc: IRect, a interface of rect's business.
	author: Musoucrow
	since: 2018-12-18
	alter: 2018-12-28
]]--

local _SYNTAX = require("lib.syntax")

local _Rect = require("graphics.drawunit.rect")

---@class Graphics.Drawable.IRect
---@field protected _rect Graphics.Drawunit.Rect
---@field protected _rectEnabled boolean
---@field protected _width int
---@field protected _height int
local _IRect = require("core.class")()

---@param rectEnabled boolean @default=false
function _IRect:Ctor(rectEnabled)
    self._rect = _Rect.New()
    self._rectEnabled = rectEnabled or false
    self._width = 0
    self._height = 0

    assert(self._renderer, "Using IRect should init Base first .")

    if (self._rectEnabled) then
        self._renderer:AddListener("setPosition", self, self.AdjustRect)
        self._renderer:AddListener("setRadian", self, self.AdjustRect_Radian)
        self._renderer:AddListener("setScale", self, self.AdjustRect)
        self._renderer:AddListener("setOrigin", self, self.AdjustRect)
    end
end

function _IRect:AdjustRect()
    if (not self._rectEnabled) then
        return
    end

    local px, py = self._renderer:GetAttri("position")
    local r = self._renderer:GetAttri("radian")
    local sx, sy = self._renderer:GetAttri("scale")
    local ox, oy = self._renderer:GetAttri("origin")
    local rw = self:GetWidth()
    local rh = self:GetHeight()

    local x = px - ox * sx - rw * _SYNTAX.BoolToNum(sx < 0)
    local y = py - oy * sy - rh * _SYNTAX.BoolToNum(sy < 0)
    local w = rw * math.abs(sx)
    local h = rh * math.abs(sy)

    self._rect:Set(x, y, w, h, r)
end

function _IRect:AdjustRect_Radian()
    if (not self._rectEnabled) then
        return
    end

    self._rect:Set(_, _, _, _, self._renderer:GetAttri("radian"))
end

---@param isOpen boolean
function _IRect:SwitchRect(isOpen)
    if (self._rectEnabled == isOpen) then
        return
    end

    self._rectEnabled = isOpen

    if (self._rectEnabled) then
        self._renderer:AddListener("setPosition", self, self.AdjustRect)
        self._renderer:AddListener("setRadian", self, self.AdjustRect_Radian)
        self._renderer:AddListener("setScale", self, self.AdjustRect)
        self._renderer:AddListener("setOrigin", self, self.AdjustRect)
    else
        self._renderer:DelListener("setPosition", self, self.AdjustRect)
        self._renderer:DelListener("setRadian", self, self.AdjustRect_Radian)
        self._renderer:DelListener("setScale", self, self.AdjustRect)
        self._renderer:DelListener("setOrigin", self, self.AdjustRect)
    end

    self:AdjustRect()
end

---@param x int
---@param y int
---@return boolean
function _IRect:CheckPoint(x, y)
    return self._rect:CheckPoint(x, y)
end

---@param rect Graphics.Drawunit.Rect
---@return boolean
function _IRect:CheckRect(rect)
    return self._rect:CheckRect(rect)
end

---@param name string
function _IRect:GetRectValue(name)
    return self._rect:Get(name)
end

---@param isReal boolean
---@return int
function _IRect:GetWidth(isReal)
    if (isReal) then
        local sx = self._renderer:GetAttri("scale")

        return math.abs(self._width * sx)
    end

    return self._width
end

---@param isReal boolean
---@return int
function _IRect:GetHeight(isReal)
    if (isReal) then
        local _, sy = self._renderer:GetAttri("scale")

        return math.abs(self._height * sy)
    end

    return self._height
end

return _IRect