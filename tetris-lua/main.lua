-- Tetris, Lua, LOVE2D framework

function love.load()

    blockSet = love.audio.newSource("sound/s0.wav", "stream")
    keyMove = love.audio.newSource("sound/s1.wav", "stream")
    rowCompletedSound = love.audio.newSource("sound/s2.wav", "stream")

    initGrid()

    moveScale = 1
    limit = 3
    currentPiece = createPiece()
    count = 0
    updateDelay = 0.5
    isPaused = true
    isSaved = false
end

function initGrid()
    _G.gridX = 16
    _G.gridY = 24

    _G.grid = {}
    for i = 2, _G.gridY do
        _G.grid[i] = {}
        for j = 2, _G.gridX do
            _G.grid[i][j] = 0
        end
    end
end

function createPiece()
    currentPiece = {}
    currentPiece.shape, currentPiece.shapeIndex = generateRandomPiece()
    currentPiece.x = 7
    currentPiece.y = 2
    return currentPiece
end

function love.keypressed(key, scancode, isrepeat)
    if key == "down" and not isPaused then
        moveDown()
    elseif key == "left" and not isPaused then
        moveLeft()
    elseif key == "right" and not isPaused then
        moveRight()
    elseif key == "space" then
        isPaused = not isPaused
    elseif key == "s" and isPaused then
        save("save.txt")
    elseif key == "l" and isPaused then
        load("save.txt")
    end
end

function save(filename)
    local file = io.open(filename, "w")

    data = ""
    data = tostring(currentPiece.shapeIndex).."\n"
    data = data..tostring(currentPiece.x).."\n"
    data = data..tostring(currentPiece.y).."\n"

    for i = 2, _G.gridY do
        for j = 2, _G.gridX do
            data = data..tostring(_G.grid[i][j]).."\n"
        end
    end

    file:write(data)

    file:close()
end

function load(filename)
    local file = io.open(filename, "r")
    local data = ""
    if file then
        data = file:read("*a")
        file:close()
    end

    local splitedData = split(data, "\n")
    currentPiece = {}

    local r, c = 2, 2

    initGrid()

    for index, value in ipairs(splitedData) do
        if index == 1 then
            currentPiece.shapeIndex = tonumber(value)
            currentPiece.shape = pieces[tonumber(value)]
        elseif index == 2 then
            currentPiece.x = tonumber(value)
        elseif index == 3 then
            currentPiece.y = tonumber(value)
        elseif tonumber(value) == 0 or tonumber(value) == 1 or tonumber(value) == 2 then
            _G.grid[r][c] = tonumber(value)
            if c == _G.gridX then
                r = r + 1
                _G.grid[r] = {}
                c = 1
            end
            c = c + 1
        end
    end
end

function split(input, separator)
    local result = {}
    for match in (input..separator):gmatch("(.-)"..separator) do
        table.insert(result, match)
    end
    return result
end

function love.update(dt)
    if not isPaused then
        moveDownAuto(dt)
    end
end

function love.draw()
    love.graphics.print("curr x: "..tostring(currentPiece.x), 10, 10)
    love.graphics.print("curr y: "..tostring(currentPiece.y), 10, 20)
    love.graphics.print("isPaused: "..tostring(isPaused), 100, 10)
    love.graphics.print("shapeIndex: "..tostring(currentPiece.shapeIndex), 100, 20)
    drawGrid()
    drawPiece()
end

function generateRandomPiece()
    pieces = {
        {{1}}, -- -
        {{1, 1}}, -- --
        {{1, 1, 1, 1}}, -- ----
        {{1}, {1,1}}, -- |_
        {{1,1}, {1}}, -- :-
        {{1}, {1}, {1}, {1}}, -- |
        {{1, 1, 1}, {1}}, -- |--
        {{1, 1, 1}, {0, 0, 1}},
        {{1, 1, 1}, {0, 1}},
        {{1, 1}, {1, 1}},
        {{1}, {1, 1}, {0,1}},
    }

    local index = love.math.random(#pieces)
    return pieces[index], index
end

function drawGrid()
    for i = 2, _G.gridY do
        for j = 2, _G.gridX do
            if _G.grid[i][j] == 0 then
                love.graphics.setColor(0,0,1)
                love.graphics.rectangle("line", (j - 1) * 30, (i - 1) * 30, 30, 30)
            elseif _G.grid[i][j] == 1 then
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle("fill", (j - 1) * 30, (i - 1) * 30, 30, 30)
            -- elseif _G.grid[i][j] == 2 then
            --     love.graphics.setColor(0,0,1)
            --     love.graphics.rectangle("fill", (4 - 1) * 30, (5 - 1) * 30, 30, 30)
            -- else
            --     love.graphics.setColor(0,0,1)
            --     love.graphics.rectangle("line", (j - 1) * 30, (i - 1) * 30, 30, 30)
            end
        end
    end
end

function drawPiece()
    for i = 1, #currentPiece.shape do
        for j = 1, #currentPiece.shape[i] do
            if currentPiece.shape[i][j] == 1 then
                love.graphics.setColor(0,1,0)
                love.graphics.rectangle("fill", (currentPiece.x + j - 2) * 30, (currentPiece.y + i - 2) * 30, 30, 30)
            end
        end
    end
end

function moveDownAuto(dt)
    count = count + dt
    while count > updateDelay do
        currentPiece.y = currentPiece.y + moveScale
        if not isValidMove() then
            currentPiece.y = currentPiece.y - moveScale
            placePieceOnGrid()
            currentPiece = createPiece()
        end
        count = count - updateDelay
    end
end

function moveDown()
    currentPiece.y = currentPiece.y + moveScale
    if not isValidMove() then
        currentPiece.y = currentPiece.y - moveScale
        placePieceOnGrid()
        currentPiece = createPiece()
    end
    love.audio.play(keyMove)
end

function moveLeft()
    currentPiece.x = currentPiece.x - moveScale
    if not isValidMove() then
        currentPiece.x = currentPiece.x + moveScale
    end
    love.audio.play(keyMove)
end

function moveRight()
    currentPiece.x = currentPiece.x + moveScale
    if not isValidMove() then
        currentPiece.x = currentPiece.x - moveScale
    end
    love.audio.play(keyMove)
end

function isValidMove()
    for i = 1, #currentPiece.shape do
        for j = 1, #currentPiece.shape[i] do
            if currentPiece.shape[i][j] == 1 then
                local grX, grY = currentPiece.x + j - 1, currentPiece.y + i - 1
                if grX < 2 or grX > _G.gridX or grY > _G.gridY or grY < 2 or _G.grid[grY][grX] == 1 then
                    return false
                end
            end
        end
    end
    return true
end

function placePieceOnGrid()
    for i = 1, #currentPiece.shape do
        for j = 1, #currentPiece.shape[i] do
            if currentPiece.shape[i][j] == 1 then
                _G.grid[currentPiece.y + i - 1][currentPiece.x + j - 1] = 1
            end
        end
    end
    love.audio.play(blockSet)
    checkForCompletedRows()
end

function checkForCompletedRows()
    for i = _G.gridY, limit, -1 do
        local rowCompleted = true
        for j = 2, _G.gridX do
            if _G.grid[i][j] == 0 then
                rowCompleted = false
                break
            end
        end
        if rowCompleted then
            for k = i, limit, -1 do
                for j = 2, _G.gridX do
                    _G.grid[k][j] = _G.grid[k - 1][j]
                    --grid[i][j] = 0
                end
            end
            love.audio.play(rowCompletedSound)
        end
    end
end

