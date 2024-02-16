local command = {}

---获取鼠标指向的实体
---@return table
function command.Sel()
    if TaxuePatch.hoverItem then
        return TaxuePatch.hoverItem
    else
        return TheInput:GetWorldEntityUnderMouse()
    end
end

function command.SetTaxueValue(value)
    local item = command.Sel()
    if not item then return nil end
    if item.equip_value then
        item.equip_value = value
    elseif item.times then
        item.times = value
    end
end

function command.Do(fn)
    GetPlayer():DoTaskInTime(0, fn)
end

function command.mprint(...)
    TaxuePatch.print(...)
end

return command
