--[[
	desc: Grass, a article of grass.
	author: Musoucrow
	since: 2018-5-30
	alter: 2018-8-10
]]--

local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Article.Grass
---@field public frameaniDatas table<number, Lib.RESOURCE.FrameaniData>
local _Grass = require("core.class")()

function _Grass.HandleData(data)
    for n=1, #data.frameani do
        data.frameani[n] = _RESMGR.GetFrameaniData(data.frameani[n])
    end
end

function _Grass:Ctor(data)
    self.frameaniDatas = data.frameani
end

return _Grass