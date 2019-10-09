--[[
	desc: Ais, a system of ai management.
	author: Musoucrow
	since: 2018-5-2
	alter: 2019-9-2
]]--

local _MAP = require("map.init")
local _AI = require("actor.service.ai")

local _Timer = require("util.gear.timer")
local _Base = require("actor.system.base")

---@class Actor.System.Ais : Actor.System
local _Ais = require("core.class")(_Base)

local function _AntiSetControlForAll(isControl)
    _AI.SetEnable(not isControl)
end

function _Ais:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        ais = true,
        input = true
    }, "ais")

    self._timer = _Timer.New(500)
end

---@param entity Actor.Entity
function _Ais:OnEnter(entity)
    local ais = entity.ais

    for k, v in pairs(ais.data) do
        if (k ~= "class") then
            local ai = v.class.NewWithConfig(entity, v) ---@type Actor.Ai
            ai.login = v.login or false
            ais.container:Add(ai, k)
        end
    end

    ais.data = nil
end

function _Ais:Update(dt)
    if (_MAP.GetLoadProcess() > 0) then
        return
    end

    self._timer:Update(dt)

    if (self._timer.isRunning) then
        return
    end

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local ais = e.ais
        local exit = false

        if (ais.enable) then
            for m=1, ais.container:GetLength() do
                local ai = ais.container:GetWithIndex(m) ---@type Actor.Ai

                if (ai.login and ai.Update) then
                    if (ai:Update(dt)) then
                        exit = true
                        break
                    end
                end
            end
        end

        if (exit) then
            self._timer:Enter()
            break
        end
    end
end

function _Ais:LateUpdate(dt)
    if (_MAP.GetLoadProcess() > 0) then
        return
    end

    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local ais = e.ais

        if (ais.enable) then
            for m=1, ais.container:GetLength() do
                local ai = ais.container:GetWithIndex(m) ---@type Actor.Ai

                if (ai.login and ai.LateUpdate) then
                    ai:LateUpdate(dt)
                end
            end
        end
    end
end

return _Ais