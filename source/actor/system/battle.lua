--[[
	desc: Battle, a system of battle.
	author: Musoucrow
	since: 2018-3-29
	alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _ECSMGR = require("actor.ecsmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _MOTION = require("actor.service.motion")
local _BATTLE = require("actor.service.battle")

local _Tweener = require("util.gear.tweener")
local _Base = require("actor.system.base")

---@class Actor.System.Battle : Actor.System
local _Battle = require("core.class")(_Base)

local _deadBoomSoundData = _RESMGR.GetSoundData("dead")
local _deathEffectData = _RESMGR.GetInstanceData("effect/death/normal")
local _flashEffectData = _RESMGR.GetInstanceData("effect/death/flash")

---@param e Actor.Entity
local function _Beaten(e)
    _BATTLE.DieTick(e.battle, e.attributes, e.transform, e.attacker, e.identity, true)
end

function _Battle:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        battle = true,
        aspect = true,
        transform = true,
        identity = true,
        attacker = true
    }, "battle")
end

---@param entity Actor.Entity
function _Battle:OnEnter(entity)
    entity.battle.shaker = _MOTION.NewShaker(entity.transform)
    entity.battle.pureColorTweener = _Tweener.New(entity.aspect.pureColor)

    if (entity.attributes) then
        entity.battle.beatenCaller:AddListener(entity, _Beaten)
    end
end

function _Battle:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        e.battle.shaker:Update(dt)

        if (not e.identity.isPaused) then
            e.battle.pureColorTweener:Update(dt)

            if (e.battle.deadProcess == 1) then
                if (e.battle.hasEffect) then
                    local pos = e.transform.position
                    local main = _ASPECT.GetPart(e.aspect) ---@type Graphics.Drawable.IRect
                    local z = pos.z - math.floor(main:GetHeight() * 0.5)
                    local param = {
                        x = pos.x,
                        y = pos.y,
                        z = pos.z,
                        entity = e
                    }
                    
                    _FACTORY.New(_deathEffectData, param)
    
                    param.z = z
                    param.entity = nil
                    _FACTORY.New(_flashEffectData, param)
                    _SOUND.Play(_deadBoomSoundData)
                end

                if (e.battle.dieSoundDatas) then
                    _SOUND.RandomPlay(e.battle.dieSoundDatas)
                end

                if (e.battle.hasDestroy) then
                    e.identity.destroyProcess = 1
                end

                e.battle.deadCaller:Call()
                e.battle.deadProcess = 2
            end
        end
    end
end

return _Battle