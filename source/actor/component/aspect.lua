--[[
	desc: Aspect, a drawable component.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-5-22
]]--

local _ASPECT = require("actor.service.aspect")

local _Caller = require("core.caller")
local _Color = require("graphics.drawunit.color")
local _Layer = require("actor.drawable.layer")

---@class Actor.Component.Aspect
---@field public layer Graphics.Drawable.Layer
---@field public isPaused boolean
---@field public rate number
---@field public color Graphics.Drawunit.Color
---@field public pureColor Graphics.Drawunit.Color
---@field public pureBlendmode string
---@field public stroke Actor.Component.Aspect.Stroke
---@field public colorTick boolean
---@field public order int
---@field public height int
---@field public avatarCaller Core.Caller
---@field public portrait Lib.RESOURCE.SpriteData
local _Aspect = require("core.class")()

local function _HandleData(data)
    if (data.type) then
        data.objClass = require("actor.drawable." .. data.type)

        if (data.objClass.HandleData) then
            data.objClass.HandleData(data)
        end
    end
end

function _Aspect.HandleData(data)
    local layer = data.layer or data

    if (#layer == 0) then
        _HandleData(layer)
    else
        for n=1, #layer do
            _HandleData(layer[n])
        end
    end
end

function _Aspect:Ctor(data)
    self.layer = _Layer.New()
    self.isPaused = false
    self.rate = 1
    self.color = data.color and _Color.New(data.color.red, data.color.green, data.color.blue, data.color.alpha) or _Color.New()
    self.height = data.height
    self.pureColor = _Color.New(_, _, _, 0)
    self.pureBlendmode = "add"
    self.avatarCaller = _Caller.New()

    ---@class Actor.Component.Aspect.Stroke
    ---@field public color Graphics.Drawunit.Color
    ---@field public scaleRate number
    self.stroke = {
        color = _Color.New(),
        scaleRate = 0,
        pixel = 1
    }

    self.colorTick = true

    local layer = data.layer or data
    local length = #layer

    if (length == 0 and layer.type) then
        local name = layer.name or "body"
        self.layer:Add(name, _, layer.objClass.NewWithConfig, layer)
    else
        for n=1, length do
            self.layer:Add(layer[n].name, _, layer[n].objClass.NewWithConfig, layer[n])
        end
    end

    self.order = data.order or 0
    _ASPECT.Sort(self)

    if (data.blendmode) then
        self.layer:SetAttri("blendmode", data.blendmode)
    end
end

return _Aspect