--[[
	desc: Attack, a state of Goblin.
	author: Musoucrow
	since: 2018-5-16
	alter: 2018-6-25
]]--

local _SOUND = require("lib.sound")

local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.duelist.goblin.attackAction")

---@class Actor.State.Duelist.Goblin.Attack:Actor.State.Duelist.Goblin.AttackAction
---@field protected _attack Actor.Gear.Attack
local _Attack = require("core.class")(_Base)

function _Attack:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
end

function _Attack:NormalUpdate()
    _Base.NormalUpdate(self)
    self._attack:Update()
end

function _Attack:OnKeyTick()
    _SOUND.Play(self._soundDataSet.swing)
    self._attack:Enter(self._attackDataSet, self._skill.attackValues[1])
end

function _Attack:Enter(...)
    _Base.Enter(self, ...)
    _SOUND.Play(self._soundDataSet.voice)
end

function _Attack:Exit()
    _Base.Exit(self)

    self._attack:Exit()
end

return _Attack