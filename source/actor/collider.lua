--[[
	desc: Collider, a solidRect set.
	author: Musoucrow
	since: 2018-5-3
	alter: 2018-6-5
]]--

local _Color = require("graphics.drawunit.color")
local _SolidRect = require("graphics.drawunit.solidRect")

---@class Actor.Collider
---@field protected _listMap table<string, table<number, Graphics.Drawunit.SolidRect>>
local _Collider = require("core.class")()

local function _Handle(v, list)
    local srect = _SolidRect.New(v.x, v.y1, v.y2, v.z, v.w, v.h)
    table.insert(list, srect)
end

---@param colliderData Actor.RESMGR.ColliderData
function _Collider:Ctor(colliderData)
    self._listMap = {}

    if (#colliderData > 0) then
        self._listMap.damage = {}

        for n=1, #colliderData do
            _Handle(colliderData[n], self._listMap.damage)
        end
    else
        if (colliderData.x) then
            self._listMap.damage = {}
            _Handle(colliderData, self._listMap.damage)
        else
            for k, v in pairs(colliderData) do
                self._listMap[k] = {}

                if (#v == 0) then
                    _Handle(v, self._listMap[k])
                else
                    for n=1, #v do
                        _Handle(v[n], self._listMap[k])
                    end
                end
            end
        end
    end
end

function _Collider:Draw()
    for k, v in pairs(self._listMap) do
        for n=1, #v do
            v[n]:Draw(_Color.red, _Color.white)
        end
    end
end

function _Collider:Set(px, py, pz, sx, sy, r)
    for k, v in pairs(self._listMap) do
        for n=1, #v do
            v[n]:Set(px, py, pz, sx, sy, r)
        end
    end
end

---@param key string @default=damage
---@return table<number, Graphics.Drawunit.SolidRect>
function _Collider:GetList(key)
    key = key or "damage"

    return self._listMap[key]
end

---@param opponent Actor.Collider
---@param selfKey string @default=damage
---@param oppKey string @default=damage
function _Collider:Collide(opponent, selfKey, oppKey)
    if (opponent == nil) then
        return false
    end

    local a = self:GetList(selfKey)
    local b = opponent:GetList(oppKey)

    if (a == nil or b == nil) then
        return false
    end

    for n=1, #a do
        for m=1, #b do
            local isdone, x, y, z = a[n]:Collide(b[m])

            if (isdone) then
                return true, x, y, z
            end
        end
    end

    return false
end

function _Collider:CheckPoint(x, y, z, key)
    local list = self:GetList(key)

    for n=1, #list do
        if (list[n]:CheckPoint(x, y, z)) then
            return true
        end
    end

    return false
end

return _Collider