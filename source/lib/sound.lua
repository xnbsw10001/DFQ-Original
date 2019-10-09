--[[
	desc: SOUND, a lib of sound.
	author: Musoucrow
	since: 2018-9-6
	alter: 2019-8-25
]]--

local _CONFIG = require("config")
local _RESOURCE = require("lib.resource") ---@type Lib.RESOURCE
local _TABLE = require("lib.table") ---@type Lib.TABLE

local _playingList = {} ---@type Source[]
local _playingListByGroup = {} ---@type table<int, Source[]>
local _queueMap = {} ---@type table<SoundData, Source[]>

---@param playingList Source[]
local function _Remove(playingList)
    for n=#playingList, 1, -1 do
        if (playingList[n]:tell() == 0 and not playingList[n]:isPlaying()) then
            table.remove(playingList, n)
        end
    end
end

local _SOUND = {} ---@class Lib.SOUND

---@param list SoundData | table<number, SoundData>
---@param group int
---@return Source
function _SOUND.RandomPlay(list, group)
    if (type(list) == "table") then
        local v = math.random(1, #list)
        _SOUND.Play(list[v], group)
    else
        _SOUND.Play(list, group)
    end
end

---@param data SoundData
---@param group int
---@return Source
function _SOUND.Play(data, group)
    group = group or 0

    if (not _queueMap[data]) then
        _queueMap[data] = {}
    end

    if (#_queueMap[data] < 2) then
        if (not _playingListByGroup[group]) then
            _playingListByGroup[group] = {}
        end

        local source = _RESOURCE.NewSource(data)
        source:setVolume(_CONFIG.setting.sound)

        table.insert(_queueMap[data], source)
        table.insert(_playingList, source)
        table.insert(_playingListByGroup[group], source)

        return source
    end
end

---@param group int @If null, that all.
function _SOUND.Stop(group)
    if (not group) then
        for n=1, #_playingList do
            _playingList[n]:stop()
        end
    elseif (_playingListByGroup[group]) then
        for n=1, #_playingListByGroup[group] do
            _playingListByGroup[group][n]:stop()
        end
    end
end

---@param group int @If null, that all.
function _SOUND.Pause(group)
    if (not group) then
        for n=1, #_playingList do
            _playingList[n]:pause()
        end
    elseif (_playingListByGroup[group]) then
        for n=1, #_playingListByGroup[group] do
            _playingListByGroup[group][n]:pause()
        end
    end
end

---@param group int @If null, that all.
function _SOUND.Resume(group)
    if (not group) then
        for n=1, #_playingList do
            _playingList[n]:resume()
        end
    elseif (_playingListByGroup[group]) then
        for n=1, #_playingListByGroup[group] do
            _playingListByGroup[group][n]:resume()
        end
    end
end

---@param group int @If null, that all.
function _SOUND.Count(group)
    if (not group) then
        return #_playingList
    elseif (_playingListByGroup[group]) then
        return #_playingListByGroup[group]
    end
end

function _SOUND.LateUpdate()
    local hasSound = false

    for k, v in pairs(_queueMap) do
        hasSound = true

        for n=1, #v do
            v[n]:play()
        end
    end

    _Remove(_playingList)

    for k, v in pairs(_playingListByGroup) do
        _Remove(v)
    end

    if (hasSound) then
        _queueMap = {}
    end
end

return _SOUND