--[[
	desc: CowardGoblin, a component of coward goblin.
	author: SkyFvcker
	since: 2018-9-17
	alter: 2019-3-31
]]--

local _STRING = require("lib.string")
local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Duelist.CowardGoblin
---@field public phyDef number
---@field public magDef number
---@field public onlyOne boolean
---@field public soundDataSet SoundData
---@field public marks table
---@field public partnerCount int
---@field public buffDatas table<int, Actor.RESMGR.BuffData>
---@field public talk table<string, string>
local _CowardGoblin = require("core.class")()

function _CowardGoblin.HandleData(data)
    data.sound = _RESOURCE.Recur(_RESMGR.GetSoundData, data.sound)

    if (data.buff) then
        for n=1, #data.buff do
            data.buff[n] = _RESMGR.NewBuffData(data.buff[n].path, data.buff[n])
        end
    end

    if (data.talk) then
        for k, v in pairs(data.talk) do
            data.talk[k] = _STRING.GetVersion(data.talk[k])
        end
    end
end

function _CowardGoblin:Ctor(data, param)
    self.phyDef = data.phyDef
    self.magDef = data.magDef
    self.soundDataSet = data.sound
    self.buffDatas = data.buff
    self.talk = data.talk
    self.onlyOne = self.buffDatas == nil
    self.marks = {}
    self.partnerCount = 0
    self.partnerMax = 0
end

return _CowardGoblin

