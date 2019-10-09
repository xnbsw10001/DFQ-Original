--[[
	desc: Pathgate, a system of path gate's business.
	author: Musoucrow
	since: 2018-6-5
	alter: 2019-5-7
]]--

local _SOUND = require("lib.sound")
local _GRAPHICS = require("lib.graphics")
local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _DUELIST = require("actor.service.duelist")
local _PATHGATE = require("actor.service.pathgate")
local _STATE = require("actor.service.state")

local _Color = require("graphics.drawunit.color")
local _Base = require("actor.system.base")

---@class Actor.System.Article.Pathgate : Actor.System
local _Pathgate = require("core.class")(_Base)

local _openSoundData = _RESMGR.GetSoundData("openGate")

function _Pathgate:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        article_pathgate = true,
        transport = true
    }, "article_pathgate")

    _DUELIST.AddListener("appeared", _, function ()
        _PATHGATE.CloseGate()
    end)

    _DUELIST.AddListener("clear", _, function ()
        _SOUND.Play(_openSoundData)
        _PATHGATE.OpenGate()
    end)
end

---@param entity Actor.Entity
function _Pathgate:OnEnter(entity)
    local aspect = entity.aspect
    local pathgate = entity.article_pathgate ---@type Actor.Component.Article.Pathgate

    local door = _ASPECT.GetPart(aspect, "door")
    pathgate.doorTweener = _GRAPHICS.NewDrawableAttriTweener(door, _Color.New(), "color")
    pathgate.doorTweener:SetTarget(_Color.New())
    pathgate.doorTweener:SetTime(pathgate.doorTime)

    local light = _ASPECT.GetPart(aspect, "light") ---@type Graphics.Drawable
    local lightColor = _Color.New(_, _, _, 0)
    pathgate.lightTweener = _GRAPHICS.NewDrawableAttriTweener(light, lightColor, "color")
    pathgate.lightTweener:SetTarget(_Color.New())
    pathgate.lightTweener:SetTime(pathgate.lightTime)
    light:SetAttri("color", lightColor:Get())

    entity.transport.enable = false
end

function _Pathgate:OnInit()
    if (_DUELIST.GetEnemyCount() == 0) then
        _PATHGATE.OpenGate()
    end
end

function _Pathgate:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local pathgate = e.article_pathgate ---@type Actor.Component.Article.Pathgate
        pathgate.doorTweener:Update(dt)
        pathgate.lightTweener:Update(dt)

        if (pathgate.isOpened and not pathgate.lightTweener.isRunning) then
            local target = pathgate.lightTweener:GetTarget() ---@type Graphics.Drawunit.Color
            target.alpha = target.alpha == 0 and 255 or 0
            pathgate.lightTweener:Enter()
        end
    end
end

return _Pathgate

