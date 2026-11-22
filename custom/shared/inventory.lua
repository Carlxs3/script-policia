function MixMetadata(a, b)
    local retval
    local aL = GetTableLength(a)
    local bL = GetTableLength(b)
    if aL < bL then
        local oldB = Shallowcopy(b)
        b = a
        a = oldB
    end
    retval = Shallowcopy(b)
    if type(retval) ~= "table" then retval = {} end
    for i, v in pairs(a) do
        retval[i] = v
    end
    return retval
end

function GetItemMetadata(item)
    if not item then return {} end
    return item.info ~= nil and (item.metadata == nil and item.info or MixMetadata(item.info, item.metadata)) or item.metadata ~= nil and item.metadata or {}
end

function GetArmouryItemsForGrade(gradeLevel)
    gradeLevel = tonumber(gradeLevel) or 0
    local items = {}
    for _, item in pairs(Config.Armory.items) do
        if gradeLevel >= (tonumber(item.grade) or 0) then
            items[#items + 1] = item
        end
    end
    return items
end