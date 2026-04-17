SASPUtils = {}

function SASPUtils.tableContains(tbl, matcher)
    for _, value in pairs(tbl) do
        if matcher(value) then
            return true, value
        end
    end
    return false, nil
end

function SASPUtils.round(value)
    return math.floor(value + 0.5)
end

function SASPUtils.getStreetLabel(coords)
    local firstStreet, crossingRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local firstStreetName = GetStreetNameFromHashKey(firstStreet)
    local crossingRoadName = GetStreetNameFromHashKey(crossingRoad)

    if crossingRoadName and crossingRoadName ~= '' then
        return ('%s / %s'):format(firstStreetName, crossingRoadName)
    end

    return firstStreetName
end

function SASPUtils.notify(message, level)
    if lib and lib.notify then
        lib.notify({
            title = 'SASP',
            description = message,
            type = level or 'inform'
        })
    else
        print(('[SASP Notify] %s'):format(message))
    end
end
