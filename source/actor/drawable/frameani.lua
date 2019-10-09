--[[
	desc: Frameani, Actor's Drawable.
	author: Musoucrow
	since: 2018-6-27
	alter: 2019-6-6
]]--

local _CONFIG = require("config")
local _TABLE = require("lib.table")
local _RESMGR = require("actor.resmgr")

local _Collider = require("actor.collider")
local _Graphics_Frameani = require("graphics.drawable.frameani")
local _Base = require("actor.drawable.base")

---@class Actor.Drawable.Frameani:Actor.Drawable
---@field public avatar Actor.Drawable.Frameani.Avatar
---@field protected _collidersPoor table
---@field protected _colliders table<int, Actor.Collider>
local _Frameani = require("core.class")(_Graphics_Frameani, _Base)

---@param frameaniData Lib.RESOURCE.FrameaniData
---@return table<number, Actor.Collider>
local function _NewColliders(frameaniData)
	if (not frameaniData) then
		return nil
	end

	local colliders = {}

	for n=1, #frameaniData.list do
		if (frameaniData.list[n].spriteData and frameaniData.list[n].spriteData.colliderData) then
			colliders[n] = _Collider.New(frameaniData.list[n].spriteData.colliderData)
		end
	end

	return colliders
end

function _Frameani.HandleData(data)
    if (data.path) then
        data.frameaniData = _RESMGR.GetFrameaniData(data.path)
        data.path = nil
    end

    if (data.avatar) then
        data.avatarData = _RESMGR.GetAvatarData(data.avatar)
        data.avatar = nil
    end

    data.avatarConfig = data.config
    data.config = nil
end

function _Frameani.NewWithConfig(upperEvent, data)
    return _Frameani.New(upperEvent, data.frameaniData, data.hasShadow, data.order, data.avatarData, data.avatarConfig, data.z)
end

---@param upperEvent event
---@param frameaniData Lib.RESOURCE.FrameaniData
---@param hasShadow boolean
---@param avatarData Actor.RESMGR.AvatarData
---@param avatarConfig table
function _Frameani:Ctor(upperEvent, frameaniData, hasShadow, order, avatarData, avatarConfig, z)
	_Base.Ctor(self, upperEvent, hasShadow, "frameani", order)
	_Graphics_Frameani.Ctor(self, upperEvent, frameaniData)

	if (avatarData) then
		---@class Actor.Drawable.Frameani.Avatar
		---@field public data Actor.RESMGR.AvatarData
		---@field public config table<string, string>
		---@field public key string
		---@field public passMap table<string, boolean>
		self.avatar = {
			data = avatarData,
			config = _TABLE.Clone(avatarConfig),
			passMap = {}
		}

		self:AdjustAvatarKey()
	end

	if (z) then
		self:SetAttri("position", _, z)
	end
end

---@param frameaniData Lib.RESOURCE.FrameaniData
---@param isOnly boolean
function _Frameani:Play(frameaniData, isOnly)
	if (frameaniData) then
		if (self._frameaniData and not self._collidersPoor) then
			self._collidersPoor = {}
			self._collidersPoor[self._frameaniData] = self._colliders
		end

		if (self._collidersPoor) then
			self._collidersPoor[frameaniData] = self._collidersPoor[frameaniData] or _NewColliders(frameaniData)
			self._colliders = self._collidersPoor[frameaniData]
		else
			self._colliders = _NewColliders(frameaniData)
		end
	end

	_Graphics_Frameani.Play(self, frameaniData, isOnly)
end

function _Frameani:AdjustAvatarKey()
	if (not self.avatar) then
		return
	end

	local keys = {}

	for k, v in pairs(self.avatar.config) do
		if (not self.avatar.passMap[k]) then
			keys[#keys + 1] = k
		end
	end

	table.sort(keys, function(a, b)
		return self.avatar.data.layer[a] < self.avatar.data.layer[b]
	end)

	for n=1, #keys do
		keys[n] = self.avatar.config[keys[n]]
	end

	self.avatar.key = table.concat(keys, "|")
end

function _Frameani:ClearCache()
	self._collidersPoor = {}
end

---@param spriteData Lib.RESOURCE.SpriteData
function _Frameani:SetData(spriteData)
	_Graphics_Frameani.SetData(self, spriteData)

	if (not self._colliders) then
		self:SetCollider()
	elseif (self._collider ~= self._colliders[self._frame]) then
		self:SetCollider(self._colliders[self._frame])
	end
end

function _Frameani:_OnDraw()
	_Graphics_Frameani._OnDraw(self)

    if (_CONFIG.debug.collider) then
        self:DrawCollider()
    end
end

return _Frameani