local ItemGiver = Class(function(self, inst)
    self.inst = inst
    self.test = nil
    self.fn = nil
end)

function ItemGiver:CollectUseActions(doer, target, actions, right)
    if target and self:test(doer, target) then
        table.insert(actions, ACTIONS.ITEMGIVER)
    end
end

return ItemGiver