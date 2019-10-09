--[[
	desc: Onceplay, a system of once play.
	author: Musoucrow
	since: 2018-5-23
	alter: 2018-12-26
]]--

local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@class Actor.System.Onceplay : Actor.System
local _Onceplay = require("core.class")(_Base)

local function _Handle(e, tag)
    local main = _ASPECT.GetPart(e.aspect, tag) ---@type Graphics.Drawable.Frameani

    if (e.onceplay.type == "normal" and main:TickEnd()) then
        return true
    elseif (e.onceplay.type == "paused" and not e.aspect.isPaused and main:GetTick() == main:GetLength() - 1) then
        return true
    end

    return false
end

function _Onceplay:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        onceplay = true
    }, "onceplay")
end

function _Onceplay:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (not e.identity.isPaused) then
            local onceplay = e.onceplay

            if (onceplay.timer) then
                onceplay.timer:Update(dt)

                if (not onceplay.timer.isRunning) then
                    e.identity.destroyProcess = 1
                    _ASPECT.ClearCollider(e.aspect)
                end
            end

            if (e.onceplay.type) then
                local done

                if (onceplay.objs == "all") then
                    done = true

                    for k, v in e.aspect.layer:Pairs() do
                        if (not _Handle(e, k)) then
                            done = false
                            break
                        end
                    end
                else
                    done = _Handle(e, "body")
                end

                if (done) then
                    if (e.onceplay.type == "normal") then
                        e.identity.destroyProcess = 1
                        _ASPECT.ClearCollider(e.aspect)
                    elseif (e.onceplay.type == "paused") then
                        e.aspect.isPaused = true
                    end
                end
            end
        end
    end
end

return _Onceplay

