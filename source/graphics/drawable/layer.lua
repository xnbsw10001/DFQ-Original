--[[
	desc: Layer, a container of Drawable.
	author: Musoucrow
	since: 2018-5-21
	alter: 2019-8-19
]]--

local _STRING = require("lib.string")

local _Base = require("graphics.drawable.base")
local _Container = require("core.container")

---@class Graphics.Drawable.Layer:Graphics.Drawable
local _Layer = require("core.class")(_Base, _Container)

---@param upperEvent event
function _Layer:Ctor(upperEvent)
	_Base.Ctor(self, upperEvent)
	_Container.Ctor(self)

    self._event.GetUpper = function()
        return self
    end
end

---@param dt number
function _Layer:Update(dt)
	for n=1, #self._list do
		self._list[n]:Update(dt)
	end
end

function _Layer:_OnDraw()
	for n=1, #self._list do
		self._list[n]:Draw()
	end
end

---@param tag string
---@param order int
---@param Func function
function _Layer:Add(tag, order, Func, ...)
	local obj = Func(self._event, ...)
	_Container.Add(self, obj, tag, order)
	
	return obj
end

function _Layer:AddOrigin(...)
	_Container.Add(self, ...)
end

---@param tag string
function _Layer:Get(tag, isOrigin)
	if (type(tag) ~= "string" or isOrigin) then
		return _Container.Get(self, tag)
	end

	local pos = 0
	local obj = self

	while (true) do
		local opos = pos + 1
		pos = string.find(tag, "#", opos)

		if (pos) then
			obj = obj:GetUpper()
		else
			tag = string.sub(tag, opos)
			break
		end
	end

	if (string.find(tag, "/")) then
		local strs = _STRING.Split(tag, "/")
	
		for n=1, #strs do
			obj = _Container.Get(obj, strs[n])
		end
	
		return obj
	else
		return _Container.Get(obj, tag)
	end
end

return _Layer