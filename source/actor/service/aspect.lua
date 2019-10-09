--[[
	desc: ASPECT, a service for aspect.
	author: Musoucrow
	since: 2018-3-27
	alter: 2019-8-29
]]--

local _TIME = require("lib.time")
local _RESMGR = require("actor.resmgr")

local _Layer = require("graphics.drawable.layer")
local _Tweener = require("util.gear.tweener")

---@class Actor.Service.ASPECT
local _ASPECT = {}

local function _Sorting(a, b)
    if (a.order == b.order) then
        return a:GetID() < b:GetID()
    else
        return a.order < b.order
    end
end

function _ASPECT.Sort(aspect)
    _Layer.Sort(aspect.layer, _Sorting)
end

---@param aspect Actor.Component.Aspect
---@param tag string
---@return Actor.Drawable | Graphics.Drawable.IRect
function _ASPECT.GetPart(aspect, tag)
    tag = tag or "body"

    return aspect.layer:Get(tag)
end

---@param aspect Actor.Component.Aspect
---@param pathSet string|table<string, string>
---@param dataSet table<string, Lib.RESOURCE.FrameaniData>
function _ASPECT.StuffFrameaniDataSet(aspect, pathSet, dataSet)
    if (type(pathSet) == "table") then
        for k, v in pairs(pathSet) do
            local drawable = aspect.layer:Get(k) ---@type Actor.Drawable.Frameani

            if (drawable:GetType() == "frameani") then
                dataSet[k] = _RESMGR.GetFrameaniData(v, _, drawable.avatar)
            end
        end
    else
        for k, v in aspect.layer:Pairs() do
            if (v:GetType() == "frameani") then
                dataSet[k] = _RESMGR.GetFrameaniData(pathSet, _, v.avatar)
            end
        end
    end
end

---@param aspect Actor.Component.Aspect
---@param dataSet Lib.RESOURCE.FrameaniData|table<string, Lib.RESOURCE.FrameaniData>
---@param isOnly boolean
function _ASPECT.Play(aspect, dataSet, isOnly)
    if (dataSet.list) then --dataSet is data
        local part = _ASPECT.GetPart(aspect)
        part:Play(dataSet, isOnly)

        return
    end

    for k, v in pairs(dataSet) do
        local part = _ASPECT.GetPart(aspect, k)

        if (part) then
            part:Play(v, isOnly)
        end
    end
end

---@param aspect Actor.Component.Aspect
function _ASPECT.ClearCollider(aspect)
    for k, v in aspect.layer:Pairs() do
        v:SetCollider()
    end
end

---@param aspect Actor.Component.Aspect
---@param avatarPart string
---@param path string
---@param tag string @Part's tag, default="body"
function _ASPECT.SetPartAvatar(aspect, avatarPart, path, tag)
    tag = tag or "body"
    local drawable = aspect.layer:Get(tag) ---@type Actor.Drawable.Frameani
    drawable.avatar.config[avatarPart] = path
    drawable:AdjustAvatarKey()
end

---@param aspect Actor.Component.Aspect
---@param avatarPart string
---@param value boolean
---@param tag string @Part's tag, default="body"
function _ASPECT.SetAvatarPass(aspect, avatarPart, value, tag)
    tag = tag or "body"
    local drawable = aspect.layer:Get(tag) ---@type Actor.Drawable.Frameani
    drawable.avatar.passMap[avatarPart] = value
end

---@param aspect Actor.Component.Aspect
---@param states Actor.Component.States
function _ASPECT.AdjustAvatar(aspect, states)
    for k, v in aspect.layer:Pairs() do
        if (v.AdjustAvatarKey) then
            v:AdjustAvatarKey()
            v:ClearCache()
        end
    end

    local STATE = require("actor.service.state")
    STATE.ReloadFrameaniData(states)
    STATE.Reset(states, true)

    local main = _ASPECT.GetPart(aspect)

    if (main and main.GetData) then
        aspect.portrait = main:GetData()
    end

    aspect.avatarCaller:Call()
    _TIME.Calmness()
end

---@param aspect Actor.Component.Aspect
---@param colliderKey string
---@return table<number, Graphics.Drawunit.SolidRect>
function _ASPECT.GetBodySolidRectList(aspect, colliderKey)
    local collider = _ASPECT.GetPart(aspect):GetCollider()

    if (collider) then
        return collider:GetList(colliderKey)
    end

    return nil
end

---@param aspect Actor.Component.Aspect
---@return Util.Gear.Tweener
function _ASPECT.NewColorTweener(aspect)
    return _Tweener.New(aspect.color, _, _, function()
        aspect.colorTick = true
    end)
end

return _ASPECT