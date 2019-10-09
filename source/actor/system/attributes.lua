--[[
	desc: Attributes, a system of attribute management.
	author: Musoucrow
	since: 2018-6-25
	alter: 2019-8-14
]]--

local _ATTRIBUTE = require("actor.service.attribute")

local _Timer = require("util.gear.timer")
local _Base = require("actor.system.base")

---@class Actor.System.Attributes : Actor.System
---@field protected _timer Util.Gear.Timer
local _Attributes = require("core.class")(_Base)

---@param e Actor.Entity
local function _Beaten(e)
    _ATTRIBUTE.AddHp(e.attributes, -e.battle.beatenConfig.damage)
end

function _Attributes:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        transform = true,
        battle = true,
        attributes = true
    }, "attributes")

    self._timer = _Timer.New(1000)
end

---@param entity Actor.Entity
function _Attributes:OnEnter(entity)
    entity.battle.beatenCaller:AddListener(entity, _Beaten)
end

---@param entity Actor.Entity
function _Attributes:OnExit(entity)
    entity.battle.beatenCaller:DelListener(entity, _Beaten)
    entity.attributes.hp = 0
end

function _Attributes:Update(dt)
    self._timer:Update(dt)

    if (not self._timer.isRunning) then
        for n=1, self._list:GetLength() do
            local e = self._list:Get(n) ---@type Actor.Entity
            local attributes = e.attributes
            local cond = (e.battle and e.battle.deadProcess == 0) or not e.battle

            if (cond and attributes.hp > 0 and attributes.hp < attributes.maxHp * attributes.recoveryRate and attributes.hpRecovery > 0) then
                local hpRecovery = math.floor(attributes.hpRecovery * (1 - (attributes.hp / attributes.maxHp)))
                _ATTRIBUTE.AddHp(attributes, hpRecovery)
            end
        end

        self._timer:Enter()
    end
end
--[[
function _Attributes:Draw()
    local font = love.graphics.getFont()

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local attributes = e.attributes
        local pos = e.transform.position
        local str = string.format("HP: %s/%s (+%s)\nMP: %s/%s (+%s)",
                attributes.hp, attributes.maxHp, attributes.hpRecovery,
                attributes.mp, attributes.maxMp, attributes.mpRecovery
        )

        love.graphics.print(str, pos.x - math.floor(font:getWidth(str) * 0.5), pos.y + pos.z)
    end
end
]]--
return _Attributes