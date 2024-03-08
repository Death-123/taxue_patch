local json = require "json"

---@class DataSave
---@field modname string
---@field path string
---@field encode boolean
---@field local_save boolean
---@field load_success boolean
---@field data string
local DataSave = Class(function(self, modname, data)
    data = data or {}
    self.modname = modname
    self.path = data.path or self:GetDefaultPath() .. (data.name or "_savedData")
    self.encode = data.encode or false
    self.local_save = data.local_save or false
    self.load_success = true
    self.data = nil
end)

---获得默认路径
---@return string defaultPath
function DataSave:GetDefaultPath()
    return KnownModIndex:GetModConfigurationPath()
end

---设置存储数据
---@param data string
---@param callback? function
function DataSave:Set(data, callback)
    SavePersistentString(self.path, data, self.encode, callback, self.local_save)
end

---获取存储数据
---@param fn fun(load_success:boolean,str:string)
function DataSave:Get(fn)
    TheSim:GetPersistentString(self.path, fn)
end

---保存数据
---@param data any
---@param callback? function
function DataSave:Save(data, callback)
    self:Set(json.encode(data), callback)
end

---加载数据
---@return boolean load_success
---@return any data
function DataSave:Load()
    local fn = function(load_success, str)
        self.load_success = load_success
        self.data = str
    end
    self:Get(fn)
    return self.load_success, self.load_success and self.data and json.decode(self.data) or nil
end

return DataSave
