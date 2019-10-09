--[[
	desc: Drawing, a system of drawing.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-8-25
]]--

local _CONFIG = require("config")
local _GRAPHICS = require("lib.graphics")
local _RESOURCE = require("lib.resource")
local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@class Actor.System.Drawing : Actor.System
local _Drawing = require("core.class")(_Base)

local _shader_white = _RESOURCE.NewShader(_RESOURCE.GetShaderData("white"))

---@param a Actor.Entity
---@param b Actor.Entity
---@return boolean
local function _Sorting(a, b)
    local order_a = a.transform.position.y + a.aspect.order
    local order_b = b.transform.position.y + b.aspect.order

    if (order_a == order_b) then
        return a.identity.id < b.identity.id
    else
        return order_a < order_b
    end
end

function _Drawing:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        transform = true,
        aspect = true,
        identity = true
    }, "drawing")
end

---@param entity Actor.Entity
function _Drawing:OnInit(entity)
    local main = _ASPECT.GetPart(entity.aspect)

    if (main and main.GetData) then
        entity.aspect.portrait = main:GetData()
    end

    if (not entity.aspect.height) then
        if (main and main.GetHeight) then
            entity.aspect.height = main:GetHeight(true)
        else
            entity.aspect.height = 0
        end
    end
end
--[[
---@param entity Actor.Entity
function _Drawing:OnExit(entity)
    _ASPECT.ClearCollider(entity.aspect)
end
]]--
function _Drawing:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local aspect = e.aspect

        if (not e.identity.isPaused and not aspect.isPaused) then
            aspect.layer:Update(dt * aspect.rate * e.identity.rate)
        end
    end
end

function _Drawing:LateUpdate()
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n)
        local aspect = e.aspect ---@type Actor.Component.Aspect
        local transform = e.transform ---@type Actor.Component.Transform
        local colliderTick = transform.positionTick or transform.scaleTick or transform.radianTick

        if (transform.positionTick) then
            local x = transform.position.x + transform.shake.x + transform.shift.x
            local y = transform.position.y + transform.position.z + transform.shake.y + transform.shift.y

            aspect.layer:SetAttri("position", x, y)
            aspect.layer.z = transform.position.z
            transform.positionTick = false
        end

        if (transform.scaleTick) then
            aspect.layer:SetAttri("scale", transform.scale.x * transform.direction, transform.scale.y)
            transform.scaleTick = false
        end

        if (transform.radianTick) then
            aspect.layer:SetAttri("radian", transform.radian.value)
            transform.radianTick = false
        end

        if (colliderTick) then
            aspect.layer:RunEvent_All("AdjustCollider")
        end

        if (aspect.colorTick) then
            aspect.layer:SetAttri("color", aspect.color:Get())
            aspect.colorTick = false
        end
    end

    self._list:Sort(_Sorting)
end

function _Drawing:Draw()
    local length = self._list:GetLength()

    if (_CONFIG.setting.shadow) then
        for n=1, length do
            self._list:Get(n).aspect.layer:RunEvent_All("DrawShadow")
        end
    end

    _GRAPHICS.SetColor(255, 255, 255, 255)

    for n=1, length do
        local e = self._list:Get(n) ---@type Actor.Entity
        local aspect = e.aspect

        if (aspect.stroke.scaleRate >= 1) then
            _GRAPHICS.SetShader(_shader_white)
            _GRAPHICS.SetColor(aspect.stroke.color:Get())
            aspect.layer:RunEvent_All("DrawStroke", aspect.stroke.scaleRate, aspect.stroke.pixel)
            _GRAPHICS.SetShader()
        end

        aspect.layer:Draw()

        if (aspect.pureColor.alpha > 0) then
            _GRAPHICS.SetShader(_shader_white)
            _GRAPHICS.SetColor(aspect.pureColor:Get())
            _GRAPHICS.SetBlendmode(aspect.pureBlendmode)
            aspect.layer:RunEvent_All("DrawPurely")
            _GRAPHICS.ResetBlendmode()
            _GRAPHICS.SetShader()
        end

        if (_CONFIG.debug.ai) then
            if (aspect.path) then
                for n=1, #aspect.path - 1 do
                    love.graphics.circle("fill", aspect.path[n].x, aspect.path[n].y, 6)
                    love.graphics.line(aspect.path[n].x, aspect.path[n].y, aspect.path[n + 1].x, aspect.path[n + 1].y)
                end
            end

            if (aspect.collider) then
                aspect.collider:Draw()
            end
        end

        if (_CONFIG.debug.point) then
            e.transform.position:Draw(4)
        end
    end

    _GRAPHICS.SetColor(255, 255, 255, 255)
end

return _Drawing