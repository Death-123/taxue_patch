local command = {}

---获取鼠标指向的实体
---@return table
function command.Sel()
    local entity = TheInput.hoverinst
    if entity and entity.Transform then
        return entity
    else
        local item = entity.widget.parent.item
        return item
    end
end

function command.Do(fn)
    GetPlayer():DoTaskInTime(0, fn)
end

function command.mprint(...)
    TaxuePatch.print(...)
end

return command