--[[
	desc: AttackJudge, a Ai of judgement for battle.
	author: Musoucrow
	since: 2019-6-9
]]--

local _ASPECT = require("actor.service.aspect")
local _BATTLE = require("actor.service.battle")
local _STATE = require("actor.service.state")
local _ECSMGR = require("actor.ecsmgr")
local _RESMGR = require("actor.resmgr")

local _SolidRect = require("graphics.drawunit.solidRect")
local _Judge = require("actor.ai.judge")

local _list1 = _ECSMGR.NewComboList({
    battle = true,
    states = true
})

local _list2 = _ECSMGR.NewComboList({
    attacker = true
})

---@class Actor.Ai.AttackJudge : Actor.Ai.Judge
---@field public campType string
local _AttackJudge = require("core.class")(_Judge)

function _AttackJudge.HandleData(data)
    if (data.collider) then
        data.colliderData = _RESMGR.GetColliderData(data.collider)
        data.collider = nil
    end
end

---@param skill Actor.Skill
function _AttackJudge.NewWithConfig(entity, data, skill)
    return _AttackJudge.New(entity, data.colliderData, skill:GetKey(), data.campType)
end

---@param entity Actor.Entity
---@param colliderData Actor.RESMGR.ColliderData
---@param key string
---@param campType string @all, same, enemy, else. default=enemy
function _AttackJudge:Ctor(entity, colliderData, key, campType)
    _Judge.Ctor(self, entity, colliderData, key)

    self.campType = campType or "enemy"
end

function _AttackJudge:Select()
    local camp = self._entity.battle.camp
    local solidRectList = self.collider:GetList()

    for n=1, _list1:GetLength() do
        local e = _list1:Get(n) ---@type Actor.Entity

        if (e.battle.banCountMap.hide == 0 and self._entity ~= e) then
            if (_BATTLE.CondCamp(camp, e.battle.camp, self.campType) and _STATE.HasTag(e.states, "attack") and _SolidRect.CollideWithList(solidRectList, _ASPECT.GetBodySolidRectList(e.aspect))) then
                return e
            end
        end
    end
    --[[
    for n=1, _list2:GetLength() do
        local e = _list2:Get(n) ---@type Actor.Entity

        if (self._entity ~= e) then
            local camp2 = e.battle and e.battle.camp

            if (not camp2 and e.identity.superior and e.identity.superior.battle) then
                camp2 = e.identity.superior.battle.camp or 0
            end

            camp2 = camp2 or 0

            if (_BATTLE.CondCamp(camp, camp2, self.campType) and _SolidRect.CollideWithList(solidRectList, _ASPECT.GetBodySolidRectList(e.aspect, "attack"))) then
                return e
            end
        end
    end]]--

    return
end

return _AttackJudge