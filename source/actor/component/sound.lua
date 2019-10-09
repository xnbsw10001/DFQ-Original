--[[
	desc: Sound, a component for sound's play.
	author: Musoucrow
    since: 2019-6-26
]]--

local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Sound
---@field sounds table
---@field sources table<int, Source>
local _Sound = require("core.class")()

function _Sound.HandleData(data)
    for n=1, #data do
        data[n].path = _RESMGR.GetSoundData(data[n].path)
    end
end

function _Sound:Ctor(data)
    self.sounds = data
end

return _Sound