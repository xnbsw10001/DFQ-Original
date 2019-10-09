--[[
	desc: ThrowStone, a system of throw stone's business.
	author: Musoucrow
	since: 2018-6-1
	alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _MOTION = require("actor.service.motion")

local _Base = require("actor.system.base")

---@class Actor.System.Bullet.ThrowStone : Actor.System
local _ThrowStone = require("core.class")(_Base)

---@param entity Actor.Entity
local function _BeObstructed(entity)
    local position = entity.transform.position
    local throwStone = entity.bullet_throwStone ---@type Actor.Component.Bullet.ThrowStone
    local param = {
        x = position.x,
        y = position.y,
        z = position.z,
        direction = -entity.transform.direction
    }

    _FACTORY.New(throwStone.effectDataMap.hitting, param)
    _SOUND.Play(throwStone.exitSoundData)
end

function _ThrowStone:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        bullet = true,
        bullet_throwStone = true
    }, "bullet_throwStone")
end

---@param entity Actor.Entity
function _ThrowStone:OnEnter(entity)
    entity.transform.obstructCaller:AddListener(entity, _BeObstructed)
end

---@param entity Actor.Entity
function _ThrowStone:OnExit(entity)
    entity.transform.obstructCaller:DelListener(entity, _BeObstructed)

    if (entity.identity.destroyProcess > 0) then
        local position = entity.transform.position
        local throwStone = entity.bullet_throwStone ---@type Actor.Component.Bullet.ThrowStone
        local param = {
            x = position.x,
            y = position.y,
            z = position.z,
            direction = -entity.transform.direction
        }

        _FACTORY.New(throwStone.effectDataMap.fragment, param)
    end
end

return _ThrowStone

