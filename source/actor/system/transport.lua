--[[
	desc: Transport, a system of transportation of map.
	author: Musoucrow
    since: 2019-5-7
    alter: 2019-9-16
]]--

local _CONFIG = require("config")
local _MAP = require("map.init")
local _STATE = require("actor.service.state")
local _MOTION = require("actor.service.motion")

local _SolidRect = require("graphics.drawunit.solidRect")
local _Base = require("actor.system.base")

---@class Actor.System.Transport : Actor.System
local _Transport = require("core.class")(_Base)

function _Transport:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        transport = true
    }, "transport")
end

---@param entity Actor.Entity
function _Transport:OnEnter(entity)
    _MOTION.AdjustCollider(entity.transform, entity.transport.collider)
end

function _Transport:LateUpdate(dt)
    local user = _CONFIG.user
    local player = user.player

    if (not player) then
        return
    end

    if (_STATE.HasTag(player.states, "free")) then
        local x, y = player.transform.position:Get()

        for n=1, self._list:GetLength() do
            local e = self._list:Get(n) ---@type Actor.Entity

            if (e.transport.enable and e.transport.collider:CheckPoint(x, y)) then
                if (e.transport.type == "make") then
                    _MAP.Load(_MAP.Make(e.transport.map, e))
                else
                    _MAP.Load(e.transport.map)
                end
                
                break
            end
        end
    end
end

if (_CONFIG.debug.transport) then
    function _Transport:Draw()
        for n=1, self._list:GetLength() do
            local e = self._list:Get(n) ---@type Actor.Entity
            e.transport.collider:Draw()
        end
    end
end

return _Transport