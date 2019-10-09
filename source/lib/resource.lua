--[[
	desc: RESOURCE, a lib that encapsulate love's creating function and loading resource function.
	author: Musoucrow
	since: 2018-3-15
	alter: 2019-8-18
]]--

local _CONFIG = require("config")
local _FILE = require("lib.file")
local _TABLE = require("lib.table")
local _STRING = require("lib.string")

local _ParticleCreation = require("3rd.particleCreation")
local _Color = require("graphics.drawunit.color")

local _poolGroup = {
    image = {},
    sprite = {},
    frameani = {},
    particle = {},
    font = {},
    shader = {},
    sound = {}
}

local _meta = {__mode = 'v'}

for k, v in pairs(_poolGroup) do
    setmetatable(v, _meta)
end

---@class Lib.RESOURCE
local _RESOURCE = {}

_RESOURCE.NewShader = love.graphics.newShader
_RESOURCE.NewQuad = love.graphics.newQuad
_RESOURCE.NewParticleSystem = love.graphics.newParticleSystem

---@param font Font
---@param content string
---@return Text
function _RESOURCE.NewText(font, content)
    font = font or love.graphics.getFont()

    return love.graphics.newText(font, content)
end

---@param data Lib.RESOURCE.ParticleData
---@return ParticleSystem
function _RESOURCE.NewParticleSystemByData(data)
    return _ParticleCreation(data, data.image)
end

---@param path string
---@return Image
function _RESOURCE.NewImage(path)
    local fileData = _FILE.NewFileData("asset/image/" .. path .. ".png")
    local imageData = love.image.newImageData(fileData)

    return love.graphics.newImage(imageData)
end

---@param path string
---@return SoundData
function _RESOURCE.NewSoundData(path)
    --print(path)
    local fileData = _FILE.NewFileData("asset/sound/" .. path .. ".ogg")

    return love.sound.newSoundData(fileData)
end

function _RESOURCE.NewSource(path)
    if (type(path) ~= "string") then
        return love.audio.newSource(path)
    end

    local fileData = _FILE.NewFileData(path)

    return love.audio.newSource(fileData)
end

---@param path string
---@return Lib.RESOURCE.MusicData
function _RESOURCE.NewMusic(path)
    ---@class Lib.RESOURCE.MusicData
    ---@field source Source
    ---@field name string
    ---@field author string
    local data, path = _RESOURCE.ReadConfig(path, "config/asset/music/%s.cfg")
    data.source = _RESOURCE.NewSource("asset/music/" .. path .. ".mp3")
    data.path = path

    return data
end

---@param spriteData Lib.RESOURCE.SpriteData
local function _GetNormalization(spriteData)
    if (spriteData.quad) then
        local x, y, w, h = spriteData.quad:getViewport()
        local iw = spriteData.image:getWidth()
        local ih = spriteData.image:getHeight()

        return x / iw, y / ih, w / iw, h / ih
    else
        return 0, 0, 1, 1
    end
end

---@param path string
---@param keys table<number, string> @can null
---@return Lib.RESOURCE.SpriteData
function _RESOURCE.NewSpriteData(path, keys)
    ---@class Lib.RESOURCE.SpriteData
    ---@field image Image
    ---@field path string
    ---@field ox int
    ---@field oy int
    ---@field sx number
    ---@field sy number
    ---@field angle number
    ---@field color Graphics.Drawunit.Color
    ---@field blendmode string
    local data, path = _RESOURCE.ReadConfig(path, "config/asset/sprite/%s.cfg", keys)

    if (type(data) == "string") then
        return _RESOURCE.GetSpriteData(data, keys)
    end

    if (data) then
        local imagePath = data.image or path

        if (data.color) then
            data.color = _Color.New(data.color.r, data.color.g, data.color.b, data.color.a)
        end

        if (data.shader) then
            data.shader = _RESOURCE.GetShaderData(data.shader)
        end

        data.image = _RESOURCE.GetImage(imagePath)

        if (data.w or data.h) then
            local w = data.w or data.image:getWidth()
            local h = data.h or data.image:getHeight()

            if (data.quad) then
                local x, y = data.quad:getViewport()
                data.quad:setViewport(x, y, w, h)
            else
                data.quad = _RESOURCE.NewQuad(0, 0, w, h, data.image:getWidth(), data.image:getHeight())
            end

            data.image:setWrap("repeat", "repeat")
        end

        data.path = path
    else
        data = {image = _RESOURCE.GetImage(path), path = path}
    end

    if (data.quad) then
        local x, y, w, h = data.quad:getViewport()
        data.w = data.w or w
        data.h = data.h or h
    else
        local w, h = data.image:getDimensions()
        data.w = data.w or w
        data.h = data.h or h
    end

    data.GetNormalization = _GetNormalization

    return data
end

---@param path string
---@param keys table<number, string> @can null
---@param GetSpriteData function
---@return Lib.RESOURCE.FrameaniData
function _RESOURCE.NewFrameaniData(path, keys, GetSpriteData, ...)
    local config, path = _RESOURCE.ReadConfig(path, "config/asset/frameani/%s.cfg", keys)
    GetSpriteData = GetSpriteData or _RESOURCE.GetSpriteData
    
    ---@class Lib.RESOURCE.FrameaniData
    ---@field path string
    ---@field list table<number, Lib.RESOURCE.SpriteData>
    local data = {path = path, list = {}}
    
    for n=1, #config do
        if (config[n].sprite) then
            local spriteData = GetSpriteData(config[n].sprite, ...)

            if (config[n].support) then
                spriteData = _TABLE.Clone(spriteData)
                local sp = config[n].support

                for k, v in pairs(sp) do
                    if (k == "color") then
                        spriteData[k] = _Color.New(v.r, v.g, v.b, v.a)
                    else
                        spriteData[k] = spriteData[k] + v
                    end
                end
            end

            config[n].spriteData = spriteData
            config[n].sprite = nil
            config[n].support = nil
        end

        data.list[n] = config[n]
    end

    return data
end

---@param path string
---@param keys table<number, string> @can null
---@return Lib.RESOURCE.ParticleData
function _RESOURCE.NewParticleData(path, keys)
    ---@class Lib.RESOURCE.ParticleData
    ---@field image Image
    ---@field path string
    local data, path = _RESOURCE.ReadConfig(path, "config/asset/particle/%s.cfg", keys)

    data.image = _RESOURCE.GetImage(data.image)
    data.path = path

    if (data.drawing and data.drawing.position) then
        local pos = data.drawing.position
        pos[1] = pos[1] - 640
        pos[2] = pos[2] - 360
    end

    return data
end

---@param path string
---@param keys table<number, string> @can null
---@return Lib.RESOURCE.FontData
function _RESOURCE.NewFontData(path, keys)
    ---@class Lib.RESOURCE.FontData
    ---@field font Font
    ---@field path string
    ---@field suffix string
    ---@field glyphs string
    ---@field extraspacing int
    ---@field size int
    ---@field base int
    local data, path = _RESOURCE.ReadConfig(path, "config/asset/font/%s.cfg", keys)

    if (data) then
        data.font = _STRING.GetVersion(data.font)

        if (data.glyphs) then -- Is image font.
            data.font = love.graphics.newImageFont("asset/font/" .. data.font .. ".png", data.glyphs, data.extraspacing)
        else
            data.font = love.graphics.newFont("asset/font/" .. data.font .. data.suffix, data.size)
        end

        data.path = path
        data.base = data.base or 0
        data.font:setLineHeight(data.height or 1)

        if (type(data.base) == "table") then
            data.base = data.base[_CONFIG.setting.language]
        end

        return data
    end

    return {font = love.graphics.newFont("asset/font/" .. path .. ".ttf"), path = path, base = 0}
end

---@param path string
---@return Lib.RESOURCE.ShaderData
function _RESOURCE.NewShaderData(path)
    return _FILE.ReadFile("asset/shader/" .. path .. ".sc")
end

function _RESOURCE.Recur(Func, path, keyword, ...)
    if (type(path) == "table" and path[keyword] == nil) then
        for k, v in pairs(path) do
            path[k] = _RESOURCE.Recur(Func, v, keyword, ...)
        end

        return path
    else
        return Func(path, ...)
    end
end

---@param path string
---@param pathFormat string
---@param keys table<number, string>
---@return table, string
function _RESOURCE.ReadConfig(path, pathFormat, keys)
    if (type(path) == "table") then
        return path, path.path
    end

    local fullPath = string.format(pathFormat, path)

    if (_FILE.Exists(fullPath)) then
        local content = _FILE.ReadFile(fullPath)
        local directory = _STRING.ToDirectory(path)
        directory = string.sub(directory, 1, #directory - 1)
        content = string.gsub(content, "$0", directory)
        content = string.gsub(content, "$A", path)

        if (keys) then
            if (type(keys) == "string") then
                content = string.gsub(content, "$1", keys)
            else
                for n=1, #keys do
                    content = string.gsub(content, "$" .. n, keys[n])
                end
            end
        end

        if (string.find(content, "//")) then
            assert(nil, fullPath .. " has inconvenience path.")
        end
        
        return loadstring(content)(), path
    end

    return nil, path
end

---@param path string
---@param keys string | table<number, string>
---@return string
function _RESOURCE.GetTag(path, keys)
    local tag

    if (type(keys) == "string") then
        tag = path .. "|" .. keys
    elseif (type(keys) == "table") then
        local stringBuffer = {}
        table.insert(stringBuffer, path)

        for n=1, #keys do
            table.insert(stringBuffer, "|")
            table.insert(stringBuffer, keys[n])
        end

        tag = table.concat(stringBuffer)
    else
        tag = path
    end

    return tag
end

---@param poor table
---@param Func function
---@param path string
---@param tag string
---@return table
function _RESOURCE.GetResource(poor, Func, path, tag, ...)
    if (type(path) == "table") then
        return Func(path, ...)
    end
    
    tag = tag or path

    if (not poor[tag]) then
        local data = Func(path, ...)

        poor[tag] = data
    end

    return poor[tag]
end

---@param poor table
---@param Func function
---@param path string
---@param keys string | table<number, string>
---@return table
function _RESOURCE.GetConfigResource(poor, Func, path, keys, ...)
    return _RESOURCE.GetResource(poor, Func, path, _RESOURCE.GetTag(path, keys), keys, ...)
end

---@param path string
---@return Image
function _RESOURCE.GetImage(path)
    return _RESOURCE.GetResource(_poolGroup.image, _RESOURCE.NewImage, path)
end

---@param path string
---@return SoundData
function _RESOURCE.GetSoundData(path)
    return _RESOURCE.GetResource(_poolGroup.sound, _RESOURCE.NewSoundData, path)
end

---@param path string
---@return Lib.RESOURCE.SpriteData
function _RESOURCE.GetSpriteData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.sprite, _RESOURCE.NewSpriteData, path, keys)
end

---@param path string
---@return Lib.RESOURCE.FrameaniData
function _RESOURCE.GetFrameaniData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.frameani, _RESOURCE.NewFrameaniData, path, keys)
end

---@param path string
---@return Lib.RESOURCE.ParticleData
function _RESOURCE.GetParticleData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.particle, _RESOURCE.NewParticleData, path, keys)
end

---@param path string
---@return Lib.RESOURCE.FontData
function _RESOURCE.GetFontData(path, keys)
    return _RESOURCE.GetConfigResource(_poolGroup.font, _RESOURCE.NewFontData, path, keys)
end

---@param path string
---@return Lib.RESOURCE.ShaderData
function _RESOURCE.GetShaderData(path)
    return _RESOURCE.GetResource(_poolGroup.shader, _RESOURCE.NewShaderData, path)
end

return _RESOURCE