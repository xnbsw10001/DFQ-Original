--[[
	desc: The basic class of part of Renderer.
	author: Musoucrow
	since: 2018-3-7
	alter: 2019-9-17
]]--

local _Factory = require("graphics.drawunit.factory")

---@param tab table
local function _SetRealityMeta(self, tab)
	if (not self._drawunitGroup.reality) then
		self._drawunitGroup.reality = {}
	end
	
	setmetatable(self._drawunitGroup.reality, {__index = tab})
end

---@param type string
---@param upperDrawunit Graphics.Drawunit
---@param isSame boolean
---@return table
local function _CreateDrawunitGroup(self, type, upperDrawunit, isSame, ...)
	---@class Graphics.Renderer.Part.DrawunitGroup
	local drawunitGroup = {}
	
	drawunitGroup.base = _Factory(type, ...)
	
	if (upperDrawunit) then
		drawunitGroup.upper = upperDrawunit
		
		if (isSame) then
			drawunitGroup.synthetic = drawunitGroup.base
		else
			drawunitGroup.synthetic = _Factory(type, ...)
		end
	end
	
	return drawunitGroup
end

---@class Graphics.Renderer.Part
---@field _upperEvent event
---@field _listenerName string
---@field _isRaw boolean
---@field _isBan boolean
---@field _drawunitGroup Graphics.Renderer.Part.DrawunitGroup
local _Base = require("core.class")()

---@param upperEvent event
---@param upperDrawunit Graphics.Drawunit
---@param listenerName string
---@param type string
---@param isSame boolean
function _Base:Ctor(upperEvent, upperDrawunit, listenerName, type, isSame, ...)
	self._upperEvent = upperEvent
	
	self._listenerName = listenerName
	self._isRaw = false
	self._isBan = false
	self._drawunitGroup = _CreateDrawunitGroup(self, type, upperDrawunit, isSame, ...) --base, upper, synthetic, reality

	--state: single, follow, free
	if (self._drawunitGroup.upper) then
		self._upperEvent.AddListenerToUpper(listenerName, self, self.Set)
		self:ChangeState("follow")
	else
		self:ChangeState("single") 
	end
end

---@param isBase boolean @can null
---@param name string
---@return ...
function _Base:Get(isBase, name)
	if (isBase) then
		return self._drawunitGroup.base:Get(name)
	else
		return self._drawunitGroup.reality:Get(name)
	end
end

function _Base:Set(...)
	self._drawunitGroup.base:Set(...)
	self:_OnSet()
	self:RefreshRaw()
	self._upperEvent.Call(self._listenerName)
end

function _Base:_OnSet()
end

---@param type string
function _Base:ChangeState(type)
	if (self._state == type) then
		return
	end
	
	self._state = type
	
	if (self._state == "follow") then
		_SetRealityMeta(self, self._drawunitGroup.synthetic)
	else	
		_SetRealityMeta(self, self._drawunitGroup.base)
	end
	
	self:_OnSet()	
	self:RefreshRaw()
end

---@param unlock boolean @can null
function _Base:SwitchLock(unlock)
	if (unlock) then
		self:ChangeState("free")
	else
		if (self._drawunitGroup.upper) then
			self:ChangeState("follow")
		else
			self:ChangeState("single")
		end
	end
end

function _Base:Apply()
	if (not self._isRaw) then
		self._drawunitGroup.reality:Apply()
	end
end

function _Base:Reset()
	if (self._drawunitGroup.upper) then
		self._drawunitGroup.upper:Apply()
	end
end

function _Base:RefreshRaw()
	if (self._isBan) then
		self._isRaw = true
	elseif (self._state == "follow") then
		self._isRaw = self._drawunitGroup.base:IsRaw()
	else
		self._isRaw = false
	end
end

---@param isBan boolean
function _Base:SetBan(isBan)
	self._isBan = isBan
	self:RefreshRaw()
end

function _Base:GetDrawunit_Reality()
	return self._drawunitGroup.reality
end

return _Base