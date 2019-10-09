--[[
	desc: Buff, a skill for buff.
	author: SkyFvcker
    since: 2018-11-5
    alter: 2019-3-31
]]--

local _TABLE = require("lib.table")
local _RESMGR = require("actor.resmgr")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")

local _Skill = require("actor.skill.base")

---@class Actor.Skill.Buff:Actor.Skill
---@field protected _buffDatas table<int, Actor.RESMGR.BuffData>
local _Buff = require("core.class")(_Skill)

local function _AddData(self, data)
    local buffData = _RESMGR.NewBuffData(data.path, data)
    buffData.skill = self
    table.insert(self._buffDatas, buffData)
end

---@param entity Actor.Entity
---@param key string
---@param data Actor.RESMGR.SkillData
function _Buff:Ctor(entity, key, data)
    _Skill.Ctor(self, entity, key, data)

    self._buffDatas = {}

    if (#data.buff > 0) then
        for n=1, #data.buff do
            _AddData(self, data.buff[n])
        end
    else
        _AddData(self, data.buff)
    end
end

function _Buff:Cond()
    return true
end

---@return boolean
function _Buff:Use()
    _Skill.Use(self)

    for n=1, #self._buffDatas do
        _BUFF.AddBuff(self._entity, self._buffDatas[n])
    end
end

return _Buff