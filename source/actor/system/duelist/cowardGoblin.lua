--[[
	desc: CowardGoblin, a system of coward goblin's business.
	author: SkyFvcker
	since: 2018-9-17
	alter: 2019-5-30
]]--

local _SOUND = require("lib.sound")
local _ECSMGR = require("actor.ecsmgr")
local _DUELIST = require("actor.service.duelist")
local _ATTRIBUTE = require("actor.service.attribute")
local _BUFF = require("actor.service.buff")
local _EFFECT = require("actor.service.effect")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")

local _Base = require("actor.system.base")

---@class Actor.System.Duelist.CowardGoblin : Actor.System
local _CowardGoblin = require("core.class")(_Base)

local _powerDownEffectData = _RESMGR.GetInstanceData("effect/powerDown")

function _CowardGoblin:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        battle = true,
        duelist = true,
        duelist_cowardGoblin = true
    }, "duelist_cowardGoblin")

    ---@param entity Actor.Entity
    local OnDel = function(entity)
        local camp = entity.battle.camp

        for i = 1, self._list:GetLength() do
            local e = self._list:Get(i) ---@type Actor.Entity

            if (e.battle.camp == camp) then
                local coward = e.duelist_cowardGoblin ---@type Actor.Component.Duelist.CowardGoblin
                coward.partnerCount = coward.partnerCount - 1

                for n=1, 2 do
                    if (#coward.marks > 0) then
                        _ATTRIBUTE.Del(e.attributes, coward.marks[#coward.marks])
                        table.remove(coward.marks, #coward.marks)
                    end
                end

                _FACTORY.New(_powerDownEffectData, {entity = e})
                _SOUND.Play(coward.soundDataSet.down)

                if (coward.partnerCount == 0 and not coward.onlyOne) then
                    for n=1, #coward.buffDatas do
                        _BUFF.AddBuff(e, coward.buffDatas[n])
                    end
                    
                    _SOUND.Play(coward.soundDataSet.cry)
                    coward.onlyOne = true
                end
            end
        end
    end

    _ECSMGR.NewComboList({
        battle = true,
        duelist = true
    }, _, OnDel)
end

---@param entity Actor.Entity
function _CowardGoblin:OnInit(entity)
    local coward = entity.duelist_cowardGoblin ---@type Actor.Component.Duelist.CowardGoblin
    coward.partnerCount = _DUELIST.GetPartnerCount(entity.battle.camp) - 1

    for n=1, coward.partnerCount do
        table.insert(coward.marks, _ATTRIBUTE.Add(entity.attributes, "+", "phyDef", coward.phyDef))
        table.insert(coward.marks, _ATTRIBUTE.Add(entity.attributes, "+", "magDef", coward.magDef))
    end

    _SOUND.Play(coward.soundDataSet.up)
end

return _CowardGoblin