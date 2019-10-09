--[[
	desc: Duelist, a system of duelist management.
	author: Musoucrow
	since: 2018-6-6
	alter: 2019-9-27
]]--

local _CONFIG = require("config")
local _DIRECTOR = require("director")
local _SOUND = require("lib.sound")
local _MAP = require("map.init")
local _FACTORY = require("actor.factory")
local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _EFFECT = require("actor.service.effect")
local _BATTLE = require("actor.service.battle")
local _DUELIST = require("actor.service.duelist")
local _MOTION = require("actor.service.motion")
local _BUFF = require("actor.service.buff")

local _Color = require("graphics.drawunit.color")
local _Base = require("actor.system.base")

---@class Actor.System.Duelist : Actor.System
local _Duelist = require("core.class")(_Base)

local _overKillSoundData = _RESMGR.GetSoundData("overKill")
local _killEffectData = _RESMGR.GetInstanceData("effect/lastStrike")
local _namedColor = _Color.New(130, 255, 130, 255)
local _bossColor = _Color.New(255, 100, 255, 255)
local _inKill = false
local _bossRate = 0.1
local _bossScale = 1.3
local _inTime = 700
local _outTime = 300

local _meta = {__mode = 'v'}

local _iconPool = {}
setmetatable(_iconPool, _meta)

---@param e Actor.Entity
local function _BossBeaten(e)
    if (not _inKill and e.attributes.hp <= 0) then
        _BATTLE.Hitstop(e.attacker, e.identity, _outTime)
        _DIRECTOR.SetRate(_bossRate, _inTime, "inOutQuad")
        _MAP.camera:SetScale(_bossScale, _bossScale, _inTime, "inOutQuad")

        local h = _ASPECT.GetPart(e.aspect):GetHeight()
        local pos = e.transform.position
        local param = {
            x = pos.x,
            y = pos.y,
            z = pos.z - math.floor(h * 0.5)
        }

        _FACTORY.New(_killEffectData, param)

        e.battle.deadProcess = 1
        _inKill = true
    end
end

function _Duelist:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        duelist = true,
        battle = true,
        states = true,
        attributes = true
    }, "duelist")

    _MAP.AddLoadListener(self, self.OnClean)
end

function _Duelist:OnEnter(entity)
    if (entity.duelist.rank == 2) then
        entity.battle.beatenCaller:AddListener(entity, _BossBeaten)
    end
end

---@param entity Actor.Entity
function _Duelist:OnInit(entity)
    if (_DUELIST.IsPartner(entity.battle, entity.duelist) and _CONFIG.user.player ~= entity) then
        _DUELIST.SetAura(entity, "partner")
    elseif (entity.duelist.rank == 2) then
        _DUELIST.SetAura(entity, "boss")
    elseif (entity.duelist.rank == 1) then
        _DUELIST.SetAura(entity, "named")
    end

    entity.duelist.icon = _DUELIST.GetIcon(entity.aspect, _iconPool, entity.duelist.iconShift.x, entity.duelist.iconShift.y, 24, 24)
end

function _Duelist:OnClean(data)
    local x = data.init.x
    local y = data.init.y
    local direction = data.init.direction
    
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (e.identity.canCross) then
            e.transform.position:Set(x, y, 0)
            e.transform.positionTick = true

            if (direction) then
                e.transform.direction = direction
                e.transform.scaleTick = true
            end

            _STATE.Reset(e.states)
        end
    end
end

function _Duelist:Update(dt)
    if (_inKill and not _DIRECTOR.IsTweening()) then
        _DIRECTOR.SetRate(1, _outTime, "inOutQuad")
        _MAP.camera:SetScale(1, 1, _outTime, "inOutQuad")
        _SOUND.Play(_overKillSoundData)

        _inKill = false
    end

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (not e.identity.isPaused and e.battle.deadProcess > 0) then
            if (e.duelist.rank == 2) then
                local camp = e.battle.camp

                for m=1, self._list:GetLength() do
                    local ee = self._list:Get(m) ---@type Actor.Entity
                    
                    if ((ee.battle.camp == camp or ee.duelist.isEnemy) and ee.duelist.rank < 2) then
                        ee.battle.deadProcess = 1
                    end
                end
            end
        end
    end
end

return _Duelist