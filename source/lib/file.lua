--[[
	desc: FILE, a lib that encapsulate file function.
	author: Musoucrow
	since: 2018-3-15
	alter: 2019-9-28
]]--

local _FILE = {} ---@class Lib.FILE

---@param path string
---@return bool
function _FILE.Exists(path)	
	return love.filesystem.exists(path)
end

---@param path string @It is a full path
---@return string
function _FILE.ReadExternalFile(path)
	local file = io.open(path, "rb")

	if (not file) then
		return
	end

	local content = file:read("*a")
	file:close()
	
	return content
end

---@param path string
---@return string
function _FILE.ReadFile(path)
	return love.filesystem.read(path)
end

---@param path string
---@return table
function _FILE.ReadScript(path)
	return loadstring(_FILE.ReadFile(path))()
end

---@param path string
---@param decoder FileDecoder @file, base64
---@return FileData
function _FILE.NewFileData(path, decoder)
	return love.filesystem.newFileData(_FILE.ReadFile(path), path, decoder)
end

return _FILE