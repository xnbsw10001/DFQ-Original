--[[
	desc: Judge, a Ai of judgement.
	author: Musoucrow
	since: 2018-5-5
	alter: 2018-6-9
]]--

local _INPUT = require("actor.service.input")

local _Collider = require("actor.collider")
local _Base = require("actor.ai.base")

---@class Actor.Ai.Judge : Actor.Ai
---@field public collider Actor.Collider
---@field public key string
---@field public Select function
---@field public target Actor.Entity
local _Judge = require("core.class")(_Base)

---@param entity Actor.Entity
---@param colliderData Actor.RESMGR.ColliderData
---@param key string
---@param Select function
function _Judge:Ctor(entity, colliderData, key, Select)
    _Base.Ctor(self, entity)

    self.collider = _Collider.New(colliderData)
    self.key = key
    self.Select = Select
end

function _Judge:Tick()
    if (not self:CanRun()) then
        return false
    end

    self:AdjustCollider()
    self.target = self:Select()

    if (self.target) then
        if (self.key) then
            _INPUT.Press(self._entity.input, self.key)
        end

        return true
    end

    return false
end

function _Judge:AdjustCollider()
    local transform = self._entity.transform
    local position = transform.position
    local scale = transform.scale

    self.collider:Set(position.x, position.y, position.z, scale.x * transform.direction, scale.y)
    self._entity.aspect.collider = self.collider
end

return _Judge