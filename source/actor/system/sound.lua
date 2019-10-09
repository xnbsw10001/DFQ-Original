--[[
	desc: Sound, a system for sound business.
	author: Musoucrow
    since: 2019-6-26
]]--

local _SOUND = require("lib.sound")

local _Base = require("actor.system.base")

---@class Actor.System.Sound : Actor.System
local _Sound = require("core.class")(_Base)

function _Sound:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        sound = true
    }, "sound")
end

---@param entity Actor.Entity
function _Sound:OnEnter(entity)
    local sounds = entity.sound.sounds

    for n=1, #sounds do
        if (not sounds[n].inExit) then
            local source = _SOUND.Play(sounds[n].path)

            if (sounds[n].isLoop) then
                if (not entity.sound.sources) then
                    entity.sound.sources = {}
                end

                source:setLooping(true)
                table.insert(entity.sound.sources, source)
            end
        end
    end
end

---@param entity Actor.Entity
function _Sound:OnExit(entity)
    local sounds = entity.sound.sounds

    if (entity.sound.sources) then
        for n=1, #entity.sound.sources do
            entity.sound.sources[n]:setLooping(false)
        end
    end

    for n=1, #sounds do
        if (sounds[n].inExit) then
            _SOUND.Play(sounds[n].path)
        end
    end
end

return _Sound