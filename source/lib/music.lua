--[[
	desc: MUSIC, a lib of music.
	author: Musoucrow
    since: 2018-7-14
    alter: 2019-8-26
]]--

local _CONFIG = require("config")

local _Tweener = require("util.gear.tweener")

local _MUSIC = {time = 500} ---@class Lib.MUSIC
local _source ---@type Source
local _nextSource ---@type Source
local _data ---@type Lib.RESOURCE.MusicData
local _command
local _target = {process = 1}
local _tweener = _Tweener.New({process = 1}, _target, _, function (tweener)
    if (_source) then
        _source:setVolume(tweener:GetSubject().process * _CONFIG.setting.music)
    end
end)

---@param data Lib.RESOURCE.MusicData
function _MUSIC.Play(data)
    if (data and ((_data and _data.path == data.path))) then
        return
    end
    
    _data = data
    _nextSource = data and data.source
    _target.process = 0
    _tweener:Enter(_MUSIC.time)

    _command = "play"
end

function _MUSIC.Pause()
    if (not _source) then
        return
    end

    _target.process = 0
    _tweener:Enter(_MUSIC.time)

    _command = "pause"
end

function _MUSIC.Resume()
    if (not _source) then
        return
    end

    _target.process = 1
    _tweener:Enter(_MUSIC.time)
    _source:play()

    _command = "resume"
end

---@return boolean
function _MUSIC.IsPaused()
    return _source and _source:isPaused()
end

---@return Lib.RESOURCE.MusicData
function _MUSIC.GetData()
    return _data
end

function _MUSIC.LateUpdate(dt)
    if (_tweener.isRunning) then
        _tweener:Update(dt)

        if (not _tweener.isRunning and _target.process == 0) then
            if (_command == "play") then
                if (_source) then
                    _source:stop()
                end

                _source = _nextSource

                if (_source) then
                    _source:setVolume(0)
                    _source:setLooping(true)
                    _source:play()
                end

                _nextSource = nil

                _target.process = 1
                _tweener:Enter(_MUSIC.time)
            else -- pause
                _source:pause()
            end
        end
    end
end

function _MUSIC.AdjustVolume()
    if (_tweener.isRunning and _source) then
        return
    end

    _source:setVolume(_CONFIG.setting.music)
end

return _MUSIC