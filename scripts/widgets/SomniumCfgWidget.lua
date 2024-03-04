local SomniumWidget = require "widgets/SomniumWidget"

---@class SomniumCfgWidget:SomniumWidget
---@field _ctor fun(self,name:string,data:table):SomniumCfgWidget
---@field cfg table
local SomniumCfgWidget = Class(SomniumWidget,
    function(self, name, data)
        ---@cast self SomniumCfgWidget
        SomniumWidget._ctor(self, name or "SomniumCfgEntry")
        self.cfg = data.cfg
    end)


return SomniumCfgWidget
