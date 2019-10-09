--[[
	desc: ThrowStone, a bullet of throw stone.
	author: Musoucrow
	since: 2018-5-31
	alter: 2019-3-5
]]--

local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Bullet.ThrowStone
---@field exitSoundData SoundData
---@field effectDataMap table<string, Actor.RESMGR.InstanceData>
local _ThrowStone = require("core.class")()

function _ThrowStone.HandleData(data)
    data.soundData = _RESOURCE.Recur(_RESMGR.GetSoundData, data.exitSound)
    data.effectDataMap = _RESOURCE.Recur(_RESMGR.GetInstanceData, data.effect, "aspect")
end

function _ThrowStone:Ctor(data, param)
    self.exitSoundData = data.soundData
    self.effectDataMap = data.effectDataMap
end

return _ThrowStone