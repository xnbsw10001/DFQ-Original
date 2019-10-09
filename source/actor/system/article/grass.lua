--[[
	desc: Grass, a system of grass's business.
	author: Musoucrow
	since: 2018-5-30
	alter: 2018-12-26
]]--

local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@param grass Actor.Component.Article.Grass
---@param aspect Actor.Component.Aspect
local function _PlayAnimation(grass, aspect)
    local index = grass.isDead and #grass.frameaniDatas or math.random(1, #grass.frameaniDatas)
    _ASPECT.Play(aspect, grass.frameaniDatas[index])
end

---@class Actor.System.Article.Grass : Actor.System
local _Grass = require("core.class")(_Base)

function _Grass:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        article = true,
        article_grass = true,
        aspect = true,
        identity = true
    }, "article_grass")
end

function _Grass:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local grass = e.article_grass ---@type Actor.Component.Article.Grass

        if (not e.identity.isPaused and not e.article.isDead) then
            if (_ASPECT.GetPart(e.aspect):TickEnd()) then
                _PlayAnimation(grass, e.aspect)
            end
        end
    end
end

return _Grass