local command = {}

local global = GLOBAL or _G

---获取鼠标指向的实体
---@return table
function command.Sel()
    mprint("Sel")
    if TaxuePatch.hoverItem then
        return TaxuePatch.hoverItem
    else
        return TheInput:GetWorldEntityUnderMouse()
    end
end

function command.remove()
    local item = command.Sel()
    if item and item:IsValid() then
        item:Remove()
    end
end

function command.SetTaxueValue(value)
    local item = command.Sel()
    if not item then return nil end
    if item.equip_value then
        item.equip_value = value
    elseif item.time then
        item.time = value
    end
end

function command.setFast(enable)
    local dolongaction = GetPlayer().sg.sg.states.dolongaction
    if not dolongaction then return end
    if enable then
        TaxuePatch.oldDolongaction = { tags = dolongaction.tags, onenter = dolongaction.onenter }
        dolongaction.tags = nil
        dolongaction.onenter = function (inst)
            inst.sg:GoToState("doshortaction")
        end
    else
        dolongaction.tags = TaxuePatch.oldDolongaction.tags
        dolongaction.onenter = TaxuePatch.oldDolongaction.onenter
        TaxuePatch.oldDolongaction = nil
    end
end

function command.Do(fn)
    GetPlayer():DoTaskInTime(0, fn)
end

function command.test()
    local test, err = kleiloadlua(TaxuePatch.modRoot .. "scripts/test.lua")
    if test then
        test()
    else
        TaxuePatch.mprint(err)
    end
end

function command.mprint(...)
    TaxuePatch.mprint(...)
end

function command.getArgs(fun)
    if not fun then return end
    local args = {}
    local hook = function (...)
        local info = debug.getinfo(3)
        if info.name ~= 'pcall' then return end

        for i = 1, math.huge do
            local name, value = debug.getlocal(2, i)
            if name == '(*temporary)' or not name then
                debug.sethook()
                error('')
                return
            end
            args[i] = name
        end
    end

    debug.sethook(hook, "c")
    pcall(fun)

    return unpack(args)
end

function command.reload()
    -- 热更新开始：
    package.loaded["patchlib"] = nil -- 删除缓存
    collectgarbage()                 -- 可选：触发垃圾回收（如果旧模块有资源）

    require("patchlib")
end

for name, value in pairs(command) do
    global[name] = value
end

return command
