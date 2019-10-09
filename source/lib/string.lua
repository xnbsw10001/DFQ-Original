--[[
	desc: STRING, a lib that encapsulate string function.
	author: Musoucrow
	since: 2018-8-13
	alter: 2018-12-31
]]--

local _UTF8 = require("utf8")
local _CONFIG = require("config")

---@class Lib.STRING
local _STRING = {
    colorMap = {
        w = {255, 255, 255, 255}, --white
        W = {255, 255, 230, 255},
        B = {0, 0, 0, 0}, --black
        r = {255, 100, 100, 255}, --red
        R = {255, 0, 0, 255},
        g = {180, 255, 180, 255}, --green
        b = {200, 255, 255, 255}, --blue
        y = {255, 255, 180, 255}, --yellow
        o = {255, 200, 55, 255}, --orange
        p = {255, 150, 255, 255}, --pink
        P = {255, 50, 255, 255}, --purple
        G = {192, 192, 192, 255}, --grey
        D = {233, 218, 195, 255} --dialog
    }
}

---@param map table
---@return string
function _STRING.GetVersion(map)
    if (map == nil) then
        return ""
    elseif (type(map) == "string") then
        return map
    end

    return map[_CONFIG.setting.language]
end

---@param content string
---@return table | string
function _STRING.Colorize(content)
    if (type(content) == "table" or not string.find(content, "|")) then
        return content
    end

    local list = _STRING.Split(content, "|")
    local ret = {}

    for n=1, #list do
        if (#list[n] > 1) then
            local color = n == 1 and _STRING.colorMap.w or _STRING.colorMap[string.sub(list[n], 1, 1)]
            local text = n == 1 and list[n] or string.sub(list[n], 2)

            table.insert(ret, color)
            table.insert(ret, text)
        end
    end

    return ret
end

---@param str string
---@param key string
---@return list
function _STRING.Split(str, key)
	local list = {}
	local keyLen = #key
	local pos = 1
	local at = string.find(str, key)
	
	while at do
		list[#list + 1] = string.sub(str, pos, at - 1)
		pos = at + keyLen
		at = string.find(str, key, pos)
	end
	
	list[#list + 1] = string.sub(str, pos)
	
	return list
end

---@param str string
---@return string
function _STRING.ToDirectory(str)
	local rv = string.reverse(str)
	local pos = string.find(rv, "/")

	if (pos == nil) then
		return ""
	end

	local re = string.reverse(string.sub(rv, pos))
	
	return re
end

---@param str string
---@return string
function _STRING.ToFileName(str)
	local rv = string.reverse(str)
	local pos = string.find(rv, "/")
	local re = string.reverse(string.sub(rv, 1, pos-1))

	return re
end

---@param path string
---@param directory string
---@param isDirectory boolean @default=false
---@return string
function _STRING.HandleConcisePath(path, directory, isDirectory)
	if (string.sub(path, 1, 1) == ".") then
		if (not isDirectory) then
			directory = _STRING.ToDirectory(directory)
		end

		path = directory .. string.sub(path, 2)
	end

	return path
end

---@param text string | table
---@return int
function _STRING.Len(text)
    if (type(text) == "table") then
        local len = 0

        for n=2, #text, 2 do
            len = len + _UTF8.len(text[n])
        end

        return len
    end

    return _UTF8.len(text)
end

---@param text string | table
---@param v int char count, positive and negative, no zero.
---@param reverse boolean
---@return string | table, int
function _STRING.Offset(text, v, reverse)
    if (type(text) == "table") then
        local ret = {}
        local pos = 0

        for n=2, #text, 2 do
            table.insert(ret, text[n - 1])
            local len = _STRING.Len(text[n])
            local next = pos + len
            
            if (next <= v) then
                pos = next
                table.insert(ret, text[n])

                if (pos == v) then
                    break
                end
            else
                local left = v - next
                local t = _STRING.Offset(text[n], left, reverse)
                table.insert(ret, t)
                break
            end
        end

        return ret
    end

    local offset = _UTF8.offset(text, v)

    if (reverse) then
        return string.sub(text, offset, #text), offset
    else
        return string.sub(text, 1, offset - 1), offset
    end
end

---@param text string|table
---@param count int
---@param offset int @don't need
---@return string, int
function _STRING.SplitLine(text, count, offset)
    if (type(text) == "table") then
        for n=2, #text, 2 do
            text[n], offset = _STRING.SplitLine(text[n], count, offset)
        end

        return text
    else
        offset = offset or 0
        count = count + 1
        local latePos = 1
        local pos = _UTF8.offset(text, count - offset, latePos)

        while (pos and pos < #text) do
            text = string.sub(text, 1, pos - 1) .. "\n" .. string.sub(text, pos)
            latePos = pos + 1
            pos = _UTF8.offset(text, count, latePos)
        end

        pos = pos or latePos
        return text, _UTF8.len(text, pos)
    end
end

---@param text string
---@param font Font
---@param width int
---@param offset int @don't need
---@return string, int
function _STRING.SplitLineWithFont(text, font, width, offset)
    if (type(text) == "table") then
        local lines = 0

        for n=2, #text, 2 do
            local line = 0
            text[n], line, offset = _STRING.SplitLineWithFont(text[n], font, width, offset)
            lines = lines + line - 1
        end

        return text, lines + 1
    end

    local pos = 1
    local laterPos = 1
    local laterChar = ""
    local length = 0
    local ret = ""
    local max = #text
    local lines = 0
    local nowWidth = offset or width
    offset = nil

    for p, i in _UTF8.codes(text) do
        local c = _UTF8.char(i)
        local w = font:getWidth(c)
        local isEnd = p + #c - 1 == max
        length = length + w
        
        if (length >= nowWidth or isEnd or c == "\n") then
            local pp = p
            local cc = c
            
            if (length > nowWidth) then
                pp = laterPos
                cc = laterChar
                length = w
            else
                if (isEnd) then
                    offset = nowWidth - length
                end

                length = 0
            end

            pp = pp + #cc - 1
            local s = string.sub(text, pos, pp)

            if (isEnd or c == "\n") then
                ret = ret .. s
            else
                ret = ret .. s .. "\n"
            end

            lines = lines + 1
            pos = pp + 1
            nowWidth = width
        end

        laterPos = p
        laterChar = c
    end

    if (length > 0) then
        local s = string.sub(text, pos, max)
        ret = ret .. "\n" .. s
        lines = lines + 1
    end

    return ret, lines, offset
end

---@param colorText table
---@param pos int
---@return int, int, int @line, linePos, beginPos
function _STRING.PositionToLine(colorText, pos)
    local line = 2
    local linePos
    local cur = 0

    for n=2, #colorText, 2 do
        local next = cur + #colorText[n]

        if (next <= pos) then
            cur = next

            if (cur == pos) then
                line = n
                break
            end
        else
            local left = pos - cur
            line = n
            linePos = left
            break
        end
    end

    return line, linePos, cur
end

---@param text string | table
---@param pattern string
---@param init number
---@return number, number, string
function _STRING.Find(text, pattern, init)
    if (type(text) == "table") then
        local line, linePos, pos = _STRING.PositionToLine(text, init)
        
        for n=line, #text, 2 do
            local ret = string.find(text[n], pattern, linePos)
            
            if (ret) then
                return pos + ret
            end

            linePos = nil
            pos = pos + #text[n]
        end

        return nil
    end

    return string.find(text, pattern, init)
end

---@param text string | table
---@param head number
---@param tail number
---@return string | table
function _STRING.Sub(text, head, tail)
    if (type(text) == "table") then
        local lineA, linePosA, posA = _STRING.PositionToLine(text, head)
        local lineB, linePosB, posB = _STRING.PositionToLine(text, tail)
        local ret = {text[lineA - 1]}
        
        if (lineA == lineB) then
            table.insert(ret, string.sub(text[lineA], linePosA, linePosB))
        else
            table.insert(ret, string.sub(text[lineA], linePosA))
            
            for n=lineA + 1, lineB - 1 do
                table.insert(ret, text[n])
            end
            
            table.insert(ret, string.sub(text[lineB], 0, linePosB))
        end

        return ret
    end

    return string.sub(text, head, tail)
end

---@param text string | table
---@return int
function _STRING.Size(text)
    if (type(text) == "table") then
        local size = 0

        for n=2, #text, 2 do
            size = size + #text[n]
        end

        return size
    end

    return #text
end

return _STRING