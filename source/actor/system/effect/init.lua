--[[
	desc: Effect, a system of effect management.
	author: Musoucrow
	since: 2018-5-10
	alter: 2019-3-11
]]--

local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@class Actor.System.Effect : Actor.System
local _Effect = require("core.class")(_Base)

---@param e Actor.Entity
local function _Adjust(e)
    local superior = e.identity.superior
    local x, y, z = superior.transform.position:Get()

    if (e.effect.positionType == "normal") then
        e.transform.position:Set(x, y, z)
    elseif (e.effect.positionType == "bottom") then
        e.transform.position:Set(x, y)
    elseif (e.effect.positionType == "top" or e.effect.positionType == "middle") then
        if (e.effect.positionType == "top") then
            e.transform.position:Set(x, y, z - e.effect.height)
        else
            e.transform.position:Set(x, y, z - math.floor(e.effect.height * 0.5))
        end
    elseif (e.effect.positionType) then
        local t = e.effect.positionType
        e.transform.position:Set(x + t.x * superior.transform.direction, y + t.y, z + t.z)
    end

    e.transform.positionTick = true
end

function _Effect:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        effect = true
    }, "effect")
end

---@param e Actor.Entity
function _Effect:OnInit(e)
    local superior = e.identity.superior

    if (superior and superior.aspect.height) then
        e.effect.height = superior.aspect.height
    else
        e.effect.height = e.effect.height or _ASPECT.GetPart(superior.aspect):GetHeight(true)
    end

    if (superior and e.effect.adapt) then
        local part = _ASPECT.GetPart(superior.aspect)
        local part2 = _ASPECT.GetPart(e.aspect)
        local value = math.floor((part:GetWidth(true) + part:GetHeight(true)) * 0.5)
        local w
        local h

        if (type(e.effect.adapt) ~= "boolean") then
            w = e.effect.adapt.w
            h = e.effect.adapt.h
        else
            w = part2:GetWidth()
            h = part2:GetHeight()
        end

        e.transform.scale.x = value / w
        e.transform.scale.y = value / h
        e.transform.scaleTick = true
    end

    _Adjust(e)
end

function _Effect:Update()
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (e.identity.superior) then
            local superior = e.identity.superior

            if (e.effect.lockStop) then
                e.identity.isPaused = superior.identity.isPaused
            end

            if (e.effect.lockAlpha and e.aspect.color.alpha ~= superior.aspect.color.alpha) then
                e.aspect.color.alpha = superior.aspect.color.alpha
                e.aspect.colorTick = true
            end

            if (e.effect.lockDirection and e.transform.direction ~= superior.transform.direction) then
                e.transform.direction = superior.transform.direction
                e.transform.scaleTick = true
            end

            if (e.effect.lockRate) then
                e.aspect.rate = superior.aspect.rate
            end
        end
    end
end

function _Effect:LateUpdate()
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (e.identity.superior) then
            local superior = e.identity.superior

            if (e.effect.lockLife and superior.identity.destroyProcess > 0) then
                e.identity.destroyProcess = 1
            end

            if (e.effect.positionType and superior.transform.positionTick) then
                _Adjust(e)
            end

            if (superior.states and e.effect.state and e.effect.state ~= superior.states.current) then
                e.identity.destroyProcess = 1
            end
        end
    end
end

return _Effect