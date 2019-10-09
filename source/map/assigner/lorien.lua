---@param matrixGroup table<string, Map.Matrix>
return function(config, data, matrixGroup, entry, bossProcess)
    for n=1, math.random(2, 4) do
        local x = math.random(data.scope.x + 500, data.scope.x + data.scope.w)
        local y = math.random(data.scope.y, data.scope.y + data.scope.h * 0.5)

        table.insert(data.actor, {
            path = "effect/weather/ray",
            x = x,
            y = 0
        })

        table.insert(data.actor,{
            path = "effect/weather/rayGround",
            x = x - 250,
            y = y
        })
    end

    require("map.assigner.granfloris")(config, data, matrixGroup, entry, bossProcess)
end