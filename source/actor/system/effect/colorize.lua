--[[
	desc: Colorize, a system of colorize's business.
	author: Musoucrow
    since: 2019-1-16
    alter: 2019-2-13
]]--

local _ECSMGR = require("actor.ecsmgr")
local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@class Actor.System.Effect.Colorize : Actor.System
local _Colorize = require("core.class")(_Base)

---@param colorize Actor.Component.Effect.Colorize
---@param index int
local function _ToNext(colorize)
    colorize.index = colorize.index + 1

    if (colorize.index > #colorize.motions) then
        return false
    end

    local motion = colorize.motions[colorize.index]
    colorize.colorTweener:Enter(motion.time, motion.color, motion.easing)

    return true
end

function _Colorize:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        effect_colorize = true,
    }, "effect_colorize")
end

---@param entity Actor.Entity
function _Colorize:OnEnter(entity)
    local colorize = entity.effect_colorize ---@type Actor.Component.Effect.Colorize
    colorize.colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    _ToNext(colorize)
end

function _Colorize:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (not e.identity.isPaused) then
            local colorize = e.effect_colorize ---@type Actor.Component.Effect.Colorize 
            local colorTweener = colorize.colorTweener ---@type Util.Gear.Tweener
            
            if (colorTweener) then
                colorTweener:Update(dt)

                if (not colorTweener.isRunning) then
                    if (not _ToNext(colorize)) then
                        if (colorize.mode == "loop") then
                            colorize.index = 0
                            _ToNext(colorize)
                        elseif (colorize.mode == "exit") then
                            _ECSMGR.DelComponent(e, "effect_colorize")
                        else
                            e.identity.destroyProcess = 1
                        end
                    end
                end
            end
        end
    end
end

return _Colorize