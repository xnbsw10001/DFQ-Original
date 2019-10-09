--[[
	desc: WORLD, a system set.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-8-25
]]--

local _CONFIG = require("config")
local _TABLE = require("lib.table")
local _GRAPHICS = require("lib.graphics")
local _RESOURCE = require("lib.resource")
local _ECSMGR = require("actor.ecsmgr")
local _MAP = require("map.init")

local _QuickList = require("core.quickList")
local _DigitTip = require("actor.digitTip")

local _damageTipDataMap = {
    player = _RESOURCE.GetFontData("digitTip/player"),
    other = _RESOURCE.GetFontData("digitTip/other"),
    beaten = _RESOURCE.GetFontData("digitTip/beaten"),
    hp = _RESOURCE.GetFontData("digitTip/hp"),
    mp = _RESOURCE.GetFontData("digitTip/mp")
}

local _WORLD = {isPaused = false} ---@class Actor.WORLD
local _systems ---@type table<number, Actor.System>
local _adds = {} ---@type table<int, Actor.System>
local _dels = {} ---@type table<int, Actor.System>
local _updateList = _QuickList.New()
local _lateUpdateList = _QuickList.New()
local _drawList = _QuickList.New()
local _digitTips = {} ---@type table<number, Actor.DigitTip> | table<number, Core.Gear>
local _sortTick = false
local _shader = _RESOURCE.NewShader(_RESOURCE.GetShaderData("white"))

local _player ---@type Actor.Entity

---@param a Actor.System
---@param b Actor.System
---@return boolean
local function _Sorting(a, b)
    return a:GetID() < b:GetID()
end

local function _OnClean()
    _digitTips = {}
end

function _WORLD.Init()
    local event = {
        AddSystem = function(system)
            if (system.Update and not _updateList:HasValue(system)) then
                _updateList:Add(system)
            end

            if (system.LateUpdate and not _lateUpdateList:HasValue(system)) then
                _lateUpdateList:Add(system)
            end

            if (system.Draw and not _drawList:HasValue(system)) then
                _drawList:Add(system)
            end

            _sortTick = true
        end,
        DelSystem = function(system)
            if (system.Update and _updateList:HasValue(system)) then
                _updateList:Del(system)
            end

            if (system.LateUpdate and _lateUpdateList:HasValue(system)) then
                _lateUpdateList:Del(system)
            end

            if (system.Draw and _drawList:HasValue(system)) then
                _drawList:Del(system)
            end
        end,
        Add = function(system)
            table.insert(_adds, system)
        end,
        Del = function(system)
            table.insert(_dels, system)
        end
    }

    --Init combo list
    require("actor.service.duelist")
    require("actor.service.ai")
    require("actor.service.pathgate")
    
    _systems = {
        require("actor.system.obstacle").New(event),
        require("actor.system.attacker").New(event),
        require("actor.system.effect").New(event),
        require("actor.system.transparency").New(event),
        require("actor.system.drawing").New(event),
        require("actor.system.onceplay").New(event),
        require("actor.system.battle").New(event),
        require("actor.system.ais").New(event),
        require("actor.system.states").New(event),
        require("actor.system.duelist.init").New(event),
        require("actor.system.duelist.cowardGoblin").New(event),
        require("actor.system.effect.figure").New(event),
        require("actor.system.effect.colorize").New(event),
        require("actor.system.article").New(event),
        require("actor.system.article.grass").New(event),
        require("actor.system.article.pathgate").New(event),
        require("actor.system.bullet").New(event),
        require("actor.system.bullet.throwStone").New(event),
        require("actor.system.trigger").New(event),
        require("actor.system.skills").New(event),
        require("actor.system.equipments").New(event),
        require("actor.system.buffs").New(event),
        require("actor.system.summon").New(event),
        require("actor.system.sound").New(event),
        require("actor.system.transport").New(event),
        require("actor.system.attributes").New(event),
        require("actor.system.life").New(event),
        require("actor.system.input").New(event),
    }

    --Init combo list
    require("actor.gear.attack").Init()
    require("actor.ai.battleJudge")
    require("actor.ai.attackJudge")
    require("actor.ai.searchMove")

    _MAP.AddLoadListener(self, _OnClean)
end

function _WORLD.Update(dt, rate)
    if (_WORLD.isPaused) then
        return
    end
    
    if (_ECSMGR.AddComponentTick()) then
        if (_sortTick) then
            _updateList:Sort(_Sorting)
            _lateUpdateList:Sort(_Sorting)
            _drawList:Sort(_Sorting)
            _sortTick = false
        end

        table.sort(_adds, _Sorting)
        
        for n=1, #_adds do
            _adds[n]:Enter()
        end

        for n=1, #_adds do
            _adds[n]:Init()
        end

        _adds = {}
    end

    for n=1, _updateList:GetLength() do
        _updateList:Get(n):Update(dt, rate)
    end

    for n=1, _lateUpdateList:GetLength() do
        _lateUpdateList:Get(n):LateUpdate(dt, rate)
    end

    for n=1, #_digitTips do
        _digitTips[n]:Update(dt)
    end

    if (_ECSMGR.DelComponentTick()) then
        table.sort(_dels, _Sorting)

        for n=1, #_dels do
            _dels[n]:Exit()
        end

        _dels = {}
    end
end

function _WORLD.Draw()
    for n=1, _drawList:GetLength() do
        _drawList:Get(n):Draw()
    end
    
    for n=1, #_digitTips do
        _digitTips[n]:Draw()
    end

    _GRAPHICS.SetShader(_shader)
    for n=1, #_digitTips do
        _digitTips[n]:DrawFlash()
    end
    _GRAPHICS.SetShader()
end

---@param value int
---@param type string @playerDamage
---@param x int
---@param y int
---@param isCritical boolean
---@return Actor.DigitTip
function _WORLD.AddDamageTip(value, type, x, y, isCritical)
    if (not _CONFIG.setting.digit) then
        return
    end

    local flashTime = isCritical and 100 or 0
    local scale = isCritical and 3 or 1.5
    local scaleTime = isCritical and 200 or 150
    local digitTip ---@type Actor.DigitTip
    
    for n=1, #_digitTips do
        if (not _digitTips[n].isRunning) then
            digitTip = _digitTips[n]
            break
        end
    end

    if (not digitTip) then
        digitTip = _DigitTip.New()
        table.insert(_digitTips, digitTip)
    end

    digitTip:Enter(tostring(value), _damageTipDataMap[type], x, y, scale, scaleTime, 350, 350, flashTime, -40)

    return digitTip
end

return _WORLD