--[[
	desc: MAP, game's stage.
	author: Musoucrow
	since: 2018-11-10
	alter: 2019-9-21
]]--

local _CONFIG = require("config")
local _TIME = require("lib.time")
local _SOUND = require("lib.sound")
local _MUSIC = require("lib.music")
local _SYSTEM = require("lib.system")
local _STRING = require("lib.string")
local _GRAPHICS = require("lib.graphics")
local _RESOURCE = require("lib.resource")
local _ACTOR_FACTORY = require("actor.factory")
local _ACTOR_RESMGR = require("actor.resmgr")

local _Caller = require("core.caller")
local _Curtain = require("graphics.curtain")
local _Color = require("graphics.drawunit.color")
local _Layer = require("graphics.drawable.layer")
local _Sprite = require("graphics.drawable.sprite")
local _Frameani = require("graphics.drawable.frameani")
local _Particle = require("graphics.drawable.particle")
local _BackGround = require("map.background")
local _Camera = require("map.camera")
local _Matrix = require("map.matrix")

---@class MAP
---@field camera Map.Camera
local _MAP = {
    isPaused = false,
    curtain = _Curtain.New(),
    matrixGroup = {
        normal = _Matrix.New(16),
        object = _Matrix.New(64),
        up = _Matrix.New(100),
        down = _Matrix.New(100)
    },
    info = {
        name = "",
        theme = "",
        isBoss = false,
        isTown = false,
        width = 0,
        height = 0
    },
    values = {
        bgm = {
            enable = true,
            path = nil,
            data = nil
        },
        bgs = {
            path = nil,
            source = nil
        }
    }
}

local _emptyTab = {}
local _const = {
    floorType = {"left", "middle", "right"},
    namedIndex = {1, 3},
    namedRange = {3, 4},
    normalRange = {3, 5},
    floorRange = {5, 15},
    upRange = {0.5, 1},
    summonRange = {0, 2},
    boxRange = {-1, 2},
    fairyRange = {0, 1},
    articleRange = {4, 7},
    bossMax = 8,
    runningSoundData = _RESOURCE.GetSoundData("ui/running"),
    scale = 1.3,
    cameraSpped = 280,
    backgroundRate = {
        far = 0.3,
        near = 0.2
    },
    scope = {
        wv = 0,
        hv = -8,
        uv = -50,
        dv = -40
    },
    wall = {
        left = "effect/weather/wall/left",
        right = "effect/weather/wall/right"
    }
}

local _load = {
    process = 0,
    path = nil,
    caller = _Caller.New()
}

local _event = {
    GetShift = function()
        return _MAP.camera:GetShift()
    end
}

local _layerGroup = {
    far = _BackGround.New(_event, _const.backgroundRate.far),
    near = _BackGround.New(_event, _const.backgroundRate.near),
    floor = _Sprite.New(),
    object = _Sprite.New(),
    effect = _Layer.New()
}

local function _MakeBackground(layer, path, width)
    if (not path) then
        return
    end

    local spriteData = _RESOURCE.GetSpriteData("map/" .. path)
    local count = math.ceil(width / spriteData.w)

    for n=1, count do
        layer[n] = {sprite = path, x = spriteData.w * (n - 1), y = 0}
    end
end

---@param part table|string @floor's part
---@return Map.FloorPart
local function _GetFloor(part)
    if (not part) then
        return
    end

    local path = type(part) == "table" and part[math.random(1, #part)] or part
    local spriteData = _RESOURCE.GetSpriteData("map/" .. path)

    ---@class Map.FloorPart
    return {path = path, spriteData = spriteData}
end

local function _Sorting(a, b)
    local ao = a.sprite.oy or 0
    local bo = b.sprite.oy or 0
    local ad = a.order or 0
    local bd = b.order or 0
    local ai = a.id or 0
    local bi = b.id or 0
    local av = a.y - ao + ad
    local bv = b.y - bo + bd

    if (av == bv) then
        return ai > bi
    end
    
    return av < bv
end

local function _OnLoadEnd()
    _load.process = 0
end

---@param path string | table
local function _Load(path)
    local data = _RESOURCE.ReadConfig(path, "config/map/instance/%s.cfg")
    
    _MAP.info = data.info
    _load.caller:Call(data)

    local values = _MAP.values
    
    if (_CONFIG.debug.bgm) then
        if (values.bgm.enable) then
            local musicData

            if (values.bgm.path == data.info.bgm) then
                musicData = values.bgm.data
            else
                musicData = _RESOURCE.NewMusic(data.info.bgm)
                values.bgm.data = musicData
                values.bgm.path = data.info.bgm
            end
            
            _MUSIC.Play(musicData)
        end

        if (values.bgs.path ~= data.info.bgs) then
            local source

            if (values.bgs.source) then
                values.bgs.source:stop()
            end

            values.bgs.path = data.info.bgs

            if (values.bgs.path) then
                values.bgs.source = _RESOURCE.NewSource("asset/sound/map/" .. values.bgs.path .. ".ogg")
                values.bgs.source:play()
                values.bgs.source:setVolume(_CONFIG.setting.music)
                values.bgs.source:setLooping(true)
            end
        end
    end

    local matrix = _MAP.matrixGroup.normal

    _MAP.camera:SetWorld(0, 0, data.info.width, data.info.height)
    _MAP.camera:SetPosition(0, 0, true)
    _MAP.curtain.width, _MAP.curtain.height = data.info.width, data.info.height
    matrix:Reset(data.scope.x, data.scope.y, data.scope.w, data.scope.h, true)

    if (data.obstacle) then
        for n=1, #data.obstacle do
            matrix:SetNode(data.obstacle[n][1], data.obstacle[n][2], true, true)
        end
    end

    local spriteBoard = _Sprite.New()
    local pool = {}

    _layerGroup.effect:DelAll()

    for k, v in pairs(_layerGroup) do
        if (data.layer[k]) then
            if (k == "effect") then
                for n=1, #data.layer[k] do
                    local i = data.layer[k][n]
                    local obj
                    local resData

                    if (i.type == "sprite") then
                        resData = _ACTOR_RESMGR.GetSpriteData(i.path)
                        obj = _layerGroup.effect:Add(_, _, _Sprite.New, resData)
                    elseif (i.type == "frameani") then
                        resData = _ACTOR_RESMGR.GetFrameaniData(i.path)
                        obj = _layerGroup.effect:Add(_, _, _Frameani.New, resData)
                    elseif (i.type == "particle") then
                        resData = _ACTOR_RESMGR.GetParticleData(i.path)
                        obj = _layerGroup.effect:Add(_, _, _Particle.New, resData)
                    end

                    obj:SetAttri("position", i.x, i.y)
                end
            else
                for n=1, #data.layer[k] do
                    local i = data.layer[k][n]
                    local spriteData = pool[i.sprite]
    
                    if (not spriteData) then
                        spriteData = _RESOURCE.NewSpriteData("map/" .. i.sprite)
                        pool[i.sprite] = spriteData
                    end
    
                    i.sprite = spriteData
                end

                if (k ~= "floor") then
                    table.sort(data.layer[k], _Sorting)
                end

                local canvas = _GRAPHICS.NewCanvas(data.info.width, data.info.height)
                _GRAPHICS.SetCanvas(canvas)

                for n=1, #data.layer[k] do
                    local i = data.layer[k][n]
    
                    spriteBoard:SetData(i.sprite)
                    spriteBoard:SetAttri("position", i.x, i.y)
    
                    i.sx = i.sx or 1
                    i.sy = i.sy or 1
                    local sx, sy = spriteBoard:GetAttri("scale")
    
                    spriteBoard:SetAttri("scale", i.sx * sx, i.sy * sy)
                    spriteBoard:Draw()
                end

                _GRAPHICS.SetCanvas()
                v:SetImage(canvas)
            end
        elseif (v.SetImage) then
            v:SetImage()
        end
    end

    _load.process = 1

    for n=1, #data.actor do
        _ACTOR_FACTORY.New(data.actor[n].path, data.actor[n])
    end

    if (data.movie) then
        require("movie.init").Load(data.movie)
    end
end

function _MAP.Init(OnDraw)
    local sx, sy = _SYSTEM.GetScale()
    _MAP.camera = _Camera.New(_const.cameraSpped, sx * _const.scale, sy * _const.scale)
    _MAP.camera:SetWorld(0, 0, _SYSTEM.GetStdDimensions())

    _MAP.OnDraw = OnDraw
end

function _MAP.Update(dt)
    if (_MAP.isPaused) then
        return
    end

    if (_load.process == 1) then
        if (_CONFIG.debug.map.obstacle) then
            _MAP.matrixGroup.normal:MakeSprite()
        end

        _SYSTEM.Collect()
        _load.process = 2
    end

    _MAP.camera:Update(dt)
    _MAP.curtain:Update(dt)
    _layerGroup.effect:Update(dt)
end

function _MAP.Draw()
    _MAP.camera:Apply()
    
    _layerGroup.far:Draw()
    _layerGroup.near:Draw()
    _layerGroup.effect:Draw()
    _layerGroup.floor:Draw()
    _layerGroup.object:Draw()

    _MAP.matrixGroup.normal:Draw()
    _MAP.matrixGroup.object:Draw()
    _MAP.matrixGroup.up:Draw()
    _MAP.matrixGroup.down:Draw()

    _MAP.curtain:Draw()
    _MAP.OnDraw()

    _MAP.camera:Reset()
end

---@param path string
---@param entry Actor.Entity
---@return table @data
function _MAP.Make(path, entry)
    local config = _RESOURCE.ReadConfig(path, "config/map/making/%s.cfg")
    local pathGate = entry and entry.article_pathgate or _emptyTab
    local data = {
        info = {
            name = _STRING.GetVersion(config.info.name),
            theme = config.info.theme,
            width = config.info.width[math.random(1, #config.info.width)],
            height = config.info.height[math.random(1, #config.info.height)],
            isBoss = pathGate.isBoss,
            isTown = config.info.isTown or false,
            horizon = config.floor.horizon,
            bgm = pathGate.isBoss and config.info.bossBgm or config.info.bgm,
            bgs = config.info.bgs
        },
        init = {},
        scope = {
            x = config.scope.x,
            y = config.scope.y,
            wv = config.scope.wv or _const.scope.wv,
            hv = config.scope.hv or _const.scope.hv,
            uv = config.scope.uv or _const.scope.uv,
            dv = config.scope.dv or _const.scope.dv
        },
        actor = config.actor and config.actor.custom or {},
        layer = {
            far = {},
            near = {},
            floor = {},
            object = {},
            effect = {}
        }
    }

    data.scope.w = data.info.width - data.scope.x + data.scope.wv
    data.scope.h = data.info.height - data.scope.y + data.scope.hv

    local objectMatrix = _MAP.matrixGroup.object
    local upMatrix = _MAP.matrixGroup.up
    local downMatrix = _MAP.matrixGroup.down
    local values = _MAP.values
    
    objectMatrix:Reset(data.scope.x, data.scope.y, data.scope.w, data.scope.h, true)
    upMatrix:Reset(data.scope.x, data.info.horizon + data.scope.uv, data.scope.w, upMatrix:GetGridSize(), true)
    downMatrix:Reset(data.scope.x, data.scope.y + data.scope.h + data.scope.dv, data.scope.w, downMatrix:GetGridSize(), true)

    require("map.assigner." .. data.info.theme)(config, data, _MAP.matrixGroup, entry, 0)
    
    table.insert(data.actor, {
        path = _const.wall.left,
        x = 0,
        y = data.info.height
    })

    table.insert(data.actor, {
        path = _const.wall.right,
        x = data.info.width,
        y = config.floor.horizon
    })

    _MakeBackground(data.layer.far, config.far, data.info.width)
    _MakeBackground(data.layer.near, config.near, data.info.width)

    if (config.floor) then
        local x = 0

        while (x < data.info.width) do
            local top = _GetFloor(config.floor.top)
            local extra = _GetFloor(config.floor.extra)
            local tail = _GetFloor(config.floor.tail)

            local y = config.floor.y or config.floor.horizon
            local height = config.floor.height or top.spriteData.h

            table.insert(data.layer.floor, {sprite = top.path, x = x, y = y})
            y = y + height

            while (y < data.info.height) do
                table.insert(data.layer.floor, {sprite = extra.path, x = x, y = y})
                y = y + extra.spriteData.h
            end

            if (tail) then
                table.insert(data.layer.floor, {sprite = tail.path, x = x, y = data.info.height - tail.spriteData.h})
            end

            x = x + top.spriteData.w
        end
    end

    if (config.object) then
        if (config.object.floor) then
            local a = config.object.floorRange and config.object.floorRange[1] or _const.floorRange[1]
            local b = config.object.floorRange and config.object.floorRange[2] or _const.floorRange[2]

            objectMatrix:Assign(function (x, y)
                local path = config.object.floor[math.random(1, #config.object.floor)]
                table.insert(data.layer.floor, {sprite = path, x = x, y = y})
            end, math.random(a, b), true)
        end

        if (config.object.up) then
            local w = upMatrix:GetWidth()
            local a = config.object.upRange and config.object.upRange[1] or _const.upRange[1]
            local b = config.object.upRange and config.object.upRange[2] or _const.upRange[2]

            upMatrix:Assign(function (x, y, id)
                local obj = config.object.up[math.random(1, #config.object.up)]
                table.insert(data.layer.object, {sprite = obj.sprite, x = x, y = y + obj.y, order = obj.order, id = id})
            end, math.random(math.floor(w * a), math.floor(w * b)))
        end
    end

    if (config.actor) then
        local isBoss = data.info.isBoss

        if (config.actor.enemy) then
            local normalCount = math.random(_const.normalRange[1], _const.normalRange[2])

            objectMatrix:Assign(function (x, y)
                local path = config.actor.enemy.normal[math.random(1, #config.actor.enemy.normal)]
                local direction = math.random(1, 2) == 1 and 1 or -1
                table.insert(data.actor, {path = "duelist/" .. path, x = x, y = y, direction = direction, camp = 2, isEnemy = true})
            end, normalCount)
        end

        if (config.actor.article) then
            objectMatrix:Assign(function (x, y)
                local path = config.actor.article[math.random(1, #config.actor.article)]
                table.insert(data.actor, {path = "article/" .. path, x = x, y = y})
            end, math.random(_const.articleRange[1], _const.articleRange[2]))
        end

        if (config.actor.down) then
            downMatrix:Assign(function (x, y)
                local path = config.actor.down[math.random(1, #config.actor.down)]
                table.insert(data.actor, {path = "article/" .. path, x = x, y = y, obstacle = false})
            end, math.random(0, math.floor(downMatrix:GetWidth() * 0.5)))
        end
    end

    if (_CONFIG.debug.map.up) then
        upMatrix:MakeSprite()
    end

    if (_CONFIG.debug.map.down) then
        downMatrix:MakeSprite()
    end

    if (_CONFIG.debug.map.object) then
        objectMatrix:MakeSprite()
    end

    return data
end

---@param path string
function _MAP.Load(path, adjust)
    _load.path = path
    _load.adjust = adjust

    if (not adjust) then
        local DIRECTOR = require("director")
        _SOUND.Play(_const.runningSoundData)
        DIRECTOR.Curtain(_Color.black, 0, 500, 1000, _, _, _OnLoadEnd)
    end
end

function _MAP.LoadTick()
    if (_load.path) then
        _Load(_load.path)
        _load.path = nil

        if (_load.adjust) then
            _OnLoadEnd()
        end

        _TIME.Calmness()
    end
end

---@return Map.Matrix
function _MAP.GetMatrix(key)
    key = key or "normal"

    return _MAP.matrixGroup[key]
end

function _MAP.AddLoadListener(...)
    _load.caller:AddListener(...)
end

function _MAP.DelLoadListener(...)
    _load.caller:DelListener(...)
end

---@return int @0=none, 1=waitting, 2=loading
function _MAP.GetLoadProcess()
    if (_load.path or _load.process == 1) then
        return 2
    elseif (_load.process == 2) then
        return 1
    end

    return 0
end

return _MAP