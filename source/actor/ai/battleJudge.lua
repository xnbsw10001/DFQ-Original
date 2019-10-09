--[[
	desc: BattleJudge, a Ai of judgement for battle.
	author: Musoucrow
	since: 2018-5-7
	alter: 2019-4-10
]]--

local _ASPECT = require("actor.service.aspect")
local _BATTLE = require("actor.service.battle")
local _ECSMGR = require("actor.ecsmgr")
local _RESMGR = require("actor.resmgr")

local _SolidRect = require("graphics.drawunit.solidRect")
local _Judge = require("actor.ai.judge")

local _list = _ECSMGR.NewComboList({
    battle = true,
    aspect = true
})

---@class Actor.Ai.BattleJudge : Actor.Ai.Judge
---@field public campType string
local _BattleJudge = require("core.class")(_Judge)

function _BattleJudge.HandleData(data)
    if (data.collider) then
        data.colliderData = _RESMGR.GetColliderData(data.collider)
        data.collider = nil
    end
end

---@param skill Actor.Skill
function _BattleJudge.NewWithConfig(entity, data, skill)
    return _BattleJudge.New(entity, data.colliderData, skill:GetKey(), data.campType)
end

---@param entity Actor.Entity
---@param colliderData Actor.RESMGR.ColliderData
---@param key string
---@param campType string @all, same, enemy, else. default=enemy
function _BattleJudge:Ctor(entity, colliderData, key, campType)
    _Judge.Ctor(self, entity, colliderData, key)

    self.campType = campType or "enemy"
end

function _BattleJudge:Select()
    local camp = self._entity.battle.camp
    local solidRectList = self.collider:GetList()

    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity

        if (e.battle.banCountMap.hide == 0 and self._entity ~= e) then
            if (_BATTLE.CondCamp(camp, e.battle.camp, self.campType) and _SolidRect.CollideWithList(solidRectList, _ASPECT.GetBodySolidRectList(e.aspect))) then
                return e
            end
        end
    end

    return
end

return _BattleJudge