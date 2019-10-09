local function _NewGateMap(data, laterGate, bossProcess)
    local gateMap = {
        left = laterGate == "right",
        right = laterGate == "left",
        up = laterGate == "down",
        down = laterGate == "up"
    }

    local positionMap = {}

    local gateList = {"up", "down", "left", "right"}
    local gateCount = 0
    local gateMax = bossProcess == 1 and 1 or math.random(1, 3)
    local bossRoom

    while (gateCount < gateMax) do
        local id = math.random(1, #gateList)
        local key = gateList[id]

        if (not gateMap[key]) then
            if (bossProcess == 1) then
                bossRoom = key
            end

            gateCount = gateCount + 1
            gateMap[key] = true
        end

        table.remove(gateList, id)
    end

    data.gateMap = gateMap

    return gateMap, bossRoom
end

---@param entry Actor.Entity
local function _MakeUp(x, y, bossRoom, data, matrixGroup, laterGate, bossProcess)
    local path = "article/" .. data.info.theme .. "/pathgate/up"

    if (bossRoom == "up") then
        path = path .. "Boss"
    end

    local objectMatrix = matrixGroup.object
    local upMatrix = matrixGroup.up

    local n = objectMatrix:ToNode(x, "x", true)
    local m = objectMatrix:ToNode(y, "y", true)
    local px = objectMatrix:ToPosition(n, "x", true)
    local py = objectMatrix:ToPosition(m, "y", true)
    local isEntrance = laterGate == "down"

    table.insert(data.actor, {
        path = path,
        x = x,
        y = y,
        pathgateEnable = not isEntrance and bossProcess ~= 2,
        isEntrance = isEntrance,
        portPosition = {x = px, y = py}
    })

    do
        local n = upMatrix:ToNode(x, "x", true)

        upMatrix:SetNode(n, 0, true, true)
        upMatrix:SetNode(n - 1, 0, true, true)
        upMatrix:SetNode(n + 1, 0, true, true)
    end

    do
        objectMatrix:SetNode(n, m, true, true)
        objectMatrix:SetNode(n - 1, m, true, true)
        objectMatrix:SetNode(n + 1, m, true, true)

        if (laterGate == "down") then
            data.init.x = px
            data.init.y = py
        end
    end
end

local function _MakeDown(x, y, bossRoom, data, matrixGroup, laterGate, bossProcess)
    local path = "article/" .. data.info.theme .. "/pathgate/down"

    if (bossRoom == "down") then
        path = path .. "Boss"
    end

    local objectMatrix = matrixGroup.object
    local downMatrix = matrixGroup.down

    local n = objectMatrix:ToNode(x, "x", true)
    local m = objectMatrix:ToNode(y, "y", true)
    local px = objectMatrix:ToPosition(n, "x", true)
    local py = objectMatrix:ToPosition(m, "y") + objectMatrix:GetGridSize()
    local isEntrance = laterGate == "up"

    table.insert(data.actor, {
        path = path,
        x = x,
        y = y,
        pathgateEnable = not isEntrance and bossProcess ~= 2,
        isEntrance = isEntrance,
        portPosition = {x = px, y = py}
    })

    do
        local n = downMatrix:ToNode(x, "x", true)

        downMatrix:SetNode(n, 0, true, true)
        downMatrix:SetNode(n - 1, 0, true, true)
        downMatrix:SetNode(n + 1, 0, true, true)
    end

    do
        objectMatrix:SetNode(n, m, true, true)
        objectMatrix:SetNode(n - 1, m, true, true)
        objectMatrix:SetNode(n + 1, m, true, true)

        if (laterGate == "up") then
            data.init.x = px
            data.init.y = py
        end
    end
end

local function _MakeLeft(x, y, bossRoom, data, matrixGroup, laterGate, bossProcess)
    local path = "article/" .. data.info.theme .. "/pathgate/left"

    if (bossRoom == "left") then
        path = path .. "Boss"
    end

    local objectMatrix = matrixGroup.object
    local n = objectMatrix:ToNode(x, "x", true)
    local m = objectMatrix:ToNode(y, "y", true)
    local px = objectMatrix:ToPosition(n, "x", true)
    local py = objectMatrix:ToPosition(m, "y", true)
    local isEntrance = laterGate == "right"

    table.insert(data.actor, {
        path = path,
        x = x,
        y = y,
        pathgateEnable = not isEntrance and bossProcess ~= 2,
        isEntrance = isEntrance,
        portPosition = {x = px, y = py}
    })

    objectMatrix:SetNode(n, m, true, true)
    objectMatrix:SetNode(n + 1, m, true, true)
    objectMatrix:SetNode(n + 2, m, true, true)

    if (laterGate == "right") then
        data.init.x = px
        data.init.y = py
        data.init.direction = 1
    end
end

local function _MakeRight(x, y, bossRoom, data, matrixGroup, laterGate, bossProcess)
    local path = "article/" .. data.info.theme .. "/pathgate/right"

    if (bossRoom == "right") then
        path = path .. "Boss"
    end

    local objectMatrix = matrixGroup.object
    local n = objectMatrix:ToNode(x, "x", true)
    local m = objectMatrix:ToNode(y, "y", true)
    local px = objectMatrix:ToPosition(n, "x", true)
    local py = objectMatrix:ToPosition(m, "y", true)
    local isEntrance = laterGate == "left"

    table.insert(data.actor, {
        path = path,
        x = x,
        y = y,
        pathgateEnable = not isEntrance and bossProcess ~= 2,
        isEntrance = isEntrance,
        portPosition = {x = px, y = py}
    })

    objectMatrix:SetNode(n, m, true, true)
    objectMatrix:SetNode(n - 1, m, true, true)
    objectMatrix:SetNode(n - 2, m, true, true)
    objectMatrix:SetNode(n - 1, m - 1, true, true)
    objectMatrix:SetNode(n, m - 1, true, true)

    if (laterGate == "left") then
        data.init.x = px
        data.init.y = py
        data.init.direction = -1
    end
end

return {
    NewGateMap = _NewGateMap,
    MakeUp = _MakeUp,
    MakeDown = _MakeDown,
    MakeLeft = _MakeLeft,
    MakeRight = _MakeRight,
}