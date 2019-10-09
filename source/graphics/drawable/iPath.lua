--[[
	desc: IPath, a interface of path's business.
	author: Musoucrow
	since: 2018-12-18
]]--

---@class Graphics.Drawable.IPath
---@field protected _path string
local _IPath = require("core.class")()

function _IPath:Ctor()
    self._path = ""
end

---@return string
function _IPath:GetPath()
    return self._path
end

return _IPath