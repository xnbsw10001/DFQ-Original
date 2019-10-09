--[[
	desc: Frameani, Sprite's upgrade.
	author: Musoucrow
	since: 2018-6-1
	alter: 2019-6-16
]]--

local _Timer = require("util.gear.timer")
local _Sprite = require("graphics.drawable.sprite")

---@class Graphics.Drawable.Frameani:Graphics.Drawable.Sprite
---@field protected _timer Util.Gear.Timer
---@field protected _frameaniData Lib.RESOURCE.FrameaniData
---@field protected _frame int
---@field protected _tick int
---@field protected _length int
---@field protected _forever boolean
---@field public isPaused boolean
local _Frameani = require("core.class")(_Sprite)

---@param upperEvent event
---@param frameaniData Lib.RESOURCE.FrameaniData
---@param rectEnabled boolean @default=false
function _Frameani:Ctor(upperEvent, frameaniData, rectEnabled)
	_Sprite.Ctor(self, upperEvent, _, rectEnabled)
	
	self._timer = _Timer.New()
	self._length = 0
    self._forever = false
	self.isPaused = false
	self:Play(frameaniData)
end

function _Frameani:Update(dt)
	self._tick = -1

	if (not self.isPaused and not self._forever) then
		self._timer:Update(dt)

		if (not self._timer.isRunning) then
			self._tick = self._frame

			if (self._frame == self._length) then
				self._frame = 1
			else
				self._frame = self._frame + 1
			end

			self:Adjust()
		end
	end
end

---@param frameaniData Lib.RESOURCE.FrameaniData
---@param isOnly boolean
---@return boolean
function _Frameani:Play(frameaniData, isOnly)
	if (self._frameaniData == frameaniData) then
		if (isOnly) then
			return false
		end

		self:Reset()
		self:Adjust()

		return true
	end

	self._frameaniData = frameaniData

	if (self._frameaniData) then
		self._length = #self._frameaniData.list
	else
		self._length = 0
	end

	self:Reset()
	self:Adjust()

	return true
end

function _Frameani:Adjust()
	if (self._frameaniData) then
		self:SetData(self._frameaniData.list[self._frame].spriteData)

        if (self._frameaniData.list[self._frame].time) then
            self._timer:Enter(self._frameaniData.list[self._frame].time)
        else
            self._timer:Exit()
        end

        self._forever = not self._timer.isRunning
	else
		self:SetData()
	end
end

---@param frame int
function _Frameani:Reset()
	self._frame = 1
	self._tick = 0
end

---@return int
function _Frameani:GetTick()
	return self._tick
end

---@return boolean
function _Frameani:TickEnd()
	return self._tick == self._length
end

---@return int
function _Frameani:GetFrame()
	return self._frame
end

---@return int
function _Frameani:GetLength()
	return self._length
end

---@return Lib.RESOURCE.FrameaniData
function _Frameani:GetFrameaniData()
	return self._frameaniData
end

---@return string
function _Frameani:GetPath()
	return self._frameaniData.path
end

---@return string
function _Frameani:GetSpritePath()
	return _Sprite.GetPath(self)
end

---@param time milli
function _Frameani:SetTime(time)
	self._timer.to = time
end

return _Frameani