blocks = {}
level = 2
paused = false
tilew, tileh = 16, 16
tilesetw, tileseth = 80, 32
shapes = {'s', 's', 'z', 'z', 'l', 'l', 'j', 'j', 't', 't', 'o', 'o', 'i'}
debug = false
mute = false
score = 0
function randomshape()
    local v = math.random(#shapes)
    return shapes[v]
end

function tetload()
    tchar = randomshape()
    if tchar == 'z' then
        blocks = {{5, 2}, -- 1
        {5, 1}, -- 2
        {6, 0}, -- 3
        {6, 1} -- anchor
        }
    elseif tchar == 's' then
        blocks = {{6, 2}, {6, 1}, {5, 0}, {5, 1}}
    elseif tchar == 'j' then
        blocks = {{4, 0}, {4, 1}, {6, 1}, {5, 1}}
    elseif tchar == 'l' then
        blocks = {{6, 0}, {6, 1}, {4, 1}, {5, 1}}
    elseif tchar == 'o' then
        blocks = {{5, 1}, {5, 0}, {6, 0}, {6, 1}}
    elseif tchar == 'i' then
        blocks = {{4, 0}, {6, 0}, {7, 0}, {5, 0}}
    elseif tchar == 't' then
        blocks = {{6, 0}, {5, 1}, {7, 1}, {6, 1}}
    end
end

function tetdraw()
    love.graphics.draw(tiles, Quads[tchar], blocks[1][1] * 16 * scale, blocks[1][2] * 16 * scale, 0, scale, scale)
    love.graphics.draw(tiles, Quads[tchar], blocks[2][1] * 16 * scale, blocks[2][2] * 16 * scale, 0, scale, scale)
    love.graphics.draw(tiles, Quads[tchar], blocks[3][1] * 16 * scale, blocks[3][2] * 16 * scale, 0, scale, scale)
    love.graphics.draw(tiles, Quads[tchar], blocks[4][1] * 16 * scale, blocks[4][2] * 16 * scale, 0, scale, scale)
end

function tetcheck()
    for i = 1, 4, 1 do
        if TileTable[blocks[i][2] + 1][blocks[i][1] + 1] ~= ' ' then
            time = 0
            for i, v in pairs(blocks) do
                if v[2] <= 1 then
                    love.audio.stop()
                    love.audio.play(dead)
                    state = "gameover"
                end
            end
            if state ~= "gameover" then
                score = score + 10
                tetcommit()
            end
        end
    end
end

function tetcommit()
    for i, b in ipairs(blocks) do
        TileTable[b[2]][b[1] + 1] = tchar
        -- print(i.." "..b[1].." "..b[2])
    end
    tetload()
    love.audio.play(drop)
    rowcheck()
    if debug then
        printthetable()
    end
end

function turncc()
    if tchar ~= 'o' then
        local new = {{blocks[4][1] + blocks[4][2] - blocks[1][2], blocks[1][1] + blocks[4][2] - blocks[4][1]},
                     {blocks[4][1] + blocks[4][2] - blocks[2][2], blocks[2][1] + blocks[4][2] - blocks[4][1]},
                     {blocks[4][1] + blocks[4][2] - blocks[3][2], blocks[3][1] + blocks[4][2] - blocks[4][1]}}
        local canturn = true
        for i = 1, #new, 1 do
            -- b[2]+1 > #TileTable or b[1]+2 > #TileTable[1]
            if new[i][2] > #TileTable or new[i][1] > #TileTable[1] or new[i][2] < 1 or new[i][1] < 1 or
                TileTable[new[i][2] + 2][new[i][1] + 1] ~= ' ' then
                canturn = false
            end
        end
        if canturn then
            blocks[1][1] = new[1][1]
            blocks[1][2] = new[1][2]
            blocks[2][1] = new[2][1]
            blocks[2][2] = new[2][2]
            blocks[3][1] = new[3][1]
            blocks[3][2] = new[3][2]
            love.audio.play(rot)
        end
    end
end

function turnc()
    -- x2 = (y1 + px - py)
    -- y2 = (px + py - x1 - q)
    -- To rotate the opposite direction:
    -- x2 = (px + py - y1 - q)
    -- y2 = (x1 + py - px)
    if tchar ~= 'o' then
        local new = {{blocks[1][2] + blocks[4][1] - blocks[4][2], blocks[4][1] + blocks[4][2] - blocks[1][1]},
                     {blocks[2][2] + blocks[4][1] - blocks[4][2], blocks[4][1] + blocks[4][2] - blocks[2][1]},
                     {blocks[3][2] + blocks[4][1] - blocks[4][2], blocks[4][1] + blocks[4][2] - blocks[3][1]}}

        local canturn = true
        for i = 1, #new, 1 do
            if new[i][2] > #TileTable or new[i][1] > #TileTable[1] or new[i][2] < 1 or new[i][1] < 1 or
                TileTable[new[i][2] + 2][new[i][1] + 1] ~= ' ' then
                canturn = false
            end
        end
        if canturn then
            blocks[1][1] = new[1][1]
            blocks[1][2] = new[1][2]
            blocks[2][1] = new[2][1]
            blocks[2][2] = new[2][2]
            blocks[3][1] = new[3][1]
            blocks[3][2] = new[3][2]
            love.audio.play(rot)
        end
    end

end

function rowcheck()
    columnstogo = {}
    for i = 1, #TileTable - 1, 1 do
        rowcomp = true
        for j = 1, #TileTable[i], 1 do
            if TileTable[i][j] == ' ' then
                rowcomp = false
            end
        end
        if rowcomp then
            table.insert(columnstogo, i)
        end
    end
    for i, v in ipairs(columnstogo) do
        local blankline = {'b', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b'}
        table.remove(TileTable, v)
        table.insert(TileTable, 1, blankline)
        love.audio.play(row)
        hits = hits + 1
        level = math.max(math.floor(hits / 5), level)
    end
    if #columnstogo == 1 then
        score = score + 40 * (level + 1)
    end
    if #columnstogo == 2 then
        score = score + 100 * (level + 1)
    end
    if #columnstogo == 3 then
        score = score + 300 * (level + 1)
    end
    if #columnstogo == 4 then
        score = score + 1200 * (level + 1)
    end
end

function harddrop()
    local dropped = false
    while not dropped do
        for i, b in ipairs(blocks) do
            if TileTable[blocks[i][2] + 2][blocks[i][1] + 1] ~= ' ' then
                dropped = true
                score = score + 20
            end
        end
        for i, b in ipairs(blocks) do
            b[2] = b[2] + 1
        end
    end
    tetcommit()
end

function ghostdraw()
    love.graphics.setColor(0, 0, 0)
    gblocks = {{blocks[1][1], blocks[1][2]}, {blocks[2][1], blocks[2][2]}, {blocks[3][1], blocks[3][2]},
               {blocks[4][1], blocks[4][2]}}

    local foundloc = false
    local inplace = false
    while not foundloc do
        for i, b in ipairs(gblocks) do
            if b[2] + 3 > #TileTable or TileTable[b[2] + 3][b[1] + 1] ~= ' ' then
                foundloc = true
            end
            if TileTable[b[2] + 2][b[1] + 1] ~= ' ' then
                inplace = true
            end
        end
        if not inplace then
            for i, b in ipairs(gblocks) do
                b[2] = b[2] + 1
            end
        end
    end
    love.graphics.setColor(150, 255, 236)
    for i, b in ipairs(gblocks) do
        love.graphics.rectangle("line", b[1] * 16 * scale, b[2] * 16 * scale, 16 * scale, 16 * scale, 0, scale, scale)
    end
    love.graphics.setColor(255, 255, 255)
end

function love.load()
    -- love.window.setFullscreen(true)
    state = "splash"
    sfont = love.graphics.newFont("pixa.ttf", 24 * scale)
    gfont = love.graphics.newFont("pixa.ttf", 7 * scale)
    tiles = love.graphics.newImage("testing.png")
    tiles:setFilter("nearest", "nearest")
    sfont:setFilter("nearest", "nearest")
    gfont:setFilter("nearest", "nearest")
    music = love.audio.newSource("tiwa2.ogg", "stream")
    music:setLooping(true)

    drop = love.audio.newSource("drop.wav", "static")
    rot = love.audio.newSource("rotation.wav", "static")
    dead = love.audio.newSource("overlimit.wav", "static")
    row = love.audio.newSource("row.wav", "static")
    move = love.audio.newSource("shift.wav", "static")
    pause = love.audio.newSource("pause.wav", "static")

    ghosting = false

    local quadInfo = {{'b', 48, 16}, {'s', 16, 0}, {'z', 64, 0}, {'l', 32, 0}, {'j', 64, 16}, {'t', 48, 0}, {'o', 0, 0},
                      {'i', 16, 16}, {' ', 32, 16}, {'X', 0, 16}}

    Quads = {}
    for _, info in ipairs(quadInfo) do
        Quads[info[1]] = love.graphics.newQuad(info[2], info[3], tilew, tileh, tilesetw, tileseth)
    end
    settable()
end

function newgame()
    blocks = {}
    settable()
    hits = 0
    score = 0
    level = 2
    tetload()
    state = "game"
    love.audio.play(music)
end

function settable()
    TileTable = {}
    for i = 1, gameh - 1, 1 do
        local blankline = {'b', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'b'}
        table.insert(TileTable, i, blankline)
    end
    local borderline = {'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b', 'b'}
    table.insert(TileTable, gameh, borderline)
end

function love.draw()
    if state == "game" or state == "gameover" then
        for columnIndex, column in ipairs(TileTable) do
            for rowIndex, char in ipairs(column) do
                local y, x = (columnIndex - 1) * tilew, (rowIndex - 1) * tileh
                love.graphics.draw(tiles, Quads[char], x * scale, y * scale, 0, scale, scale)
            end
        end
    end
    if state == "splash" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(sfont)
        love.graphics.printf("SIRTET", 0, 64 * scale, love.graphics.getWidth(), "center")
        love.graphics.setFont(gfont)
        love.graphics.printf("press start", 0, love.graphics.getHeight() - 64 * scale, love.graphics.getWidth(),
            "center")
    end
    if state == "game" then
        if ghosting then
            ghostdraw()
        end
        tetdraw()
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 32 * scale)
        love.graphics.setFont(gfont)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("SCORE: ", 0, 10, love.graphics.getWidth(), "center")
        love.graphics.printf("LINES: ", 0, 35, love.graphics.getWidth(), "center")
        love.graphics.printf(score, 0, 10, love.graphics.getWidth() - 80, "right")
        love.graphics.printf(hits, 0, 35, love.graphics.getWidth() - 80, "right")
        love.graphics.printf("LEVEL: ", 30, 10, love.graphics.getWidth(), "left")
        love.graphics.printf(level, 100, 10, love.graphics.getWidth(), "left")
        -- if mute then love.graphics.printf("shhh...",30,10,50,"left") end
        if paused then
            love.graphics.printf("PAUSED", 0, 28, love.graphics.getWidth(), "center")
        end
    end
    if state == "gameover" then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 32 * scale)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("SCORE: ", 0, 10, love.graphics.getWidth(), "center")
        love.graphics.printf(score, 0, 10, love.graphics.getWidth() - 64, "right")
        love.graphics.draw(tiles, Quads['X'], 1 * scale, 1 * scale, 0, scale, scale)
        love.graphics.draw(tiles, Quads['X'], love.graphics.getWidth() - tilew * scale, 1 * scale, 0, scale, scale)
    end
end

function love.update(dt)
    if state == "game" and not paused then
        if love.keyboard.isDown("down") or love.keyboard.isDown("kp2") then
            m = 5
        else
            m = 1
        end
        time = time + m * dt
        if time > 1 / level then
            for i, b in ipairs(blocks) do
                b[2] = b[2] + 1
            end
            time = 0
            tetcheck()
        end
    end
end

function love.keypressed(key)
    if state == "splash" then
        state = "game"
        tetload()
        time = 0
        hits = 0
        love.audio.play(music)
    elseif state == "game" then
		if paused and key == "q" then
			love.event.quit(0)
		end
        if not paused then
            if key == "right" or key == "kp6" then
                local canmoveright = true
                for i, b in ipairs(blocks) do
                    if b[2] + 1 > #TileTable or b[1] + 2 > #TileTable[1] or TileTable[b[2] + 1][b[1] + 2] ~= ' ' then
                        canmoveright = false
                    end
                end
                if canmoveright then
                    for i = 1, 4, 1 do
                        blocks[i][1] = blocks[i][1] + 1
                    end
                    love.audio.play(move)
                end
            end
            if key == "left" or key == "kp4" then
                local canmoveleft = true
                for i, b in ipairs(blocks) do
                    if b[2] + 1 < 1 or b[1] + 2 < 1 or TileTable[b[2] + 1][b[1]] ~= ' ' then
                        canmoveleft = false
                    end
                end
                if canmoveleft then
                    for i = 1, 4, 1 do
                        blocks[i][1] = blocks[i][1] - 1
                    end
                    love.audio.play(move)
                end
            end
            if key == "up" or key == "lalt" then
                turncc()
            end
            if key == "down" or key == "kp2" then
                love.audio.play(move)
            end
            if key == "space" then
                harddrop()
            end
            if key == "g" then
                if ghosting == true then
                    ghosting = false
                else
                    ghosting = true
                end
            end
        end
        if key == "p" then
            if paused == true then
                paused = false
                love.audio.play(music)
            else
                paused = true
                love.audio.pause()
            end
            love.audio.play(pause)
        end
        if key == "m" then
            if not mute then
                love.audio.setVolume(0)
                mute = true
            else
                love.audio.setVolume(1)
                mute = false
            end
        end
        if key == "1" then
            level = 1
        end
        if key == "2" then
            level = 2
        end
        if key == "3" then
            level = 3
        end
        if key == "4" then
            level = 4
        end
        if key == "5" then
            level = 5
        end
        if key == "6" then
            level = 6
        end
        if key == "7" then
            level = 7
        end
        if key == "8" then
            level = 8
        end
        if key == "9" then
            level = 9
        end
        if key == "0" then
            level = 30
        end
    elseif state == "gameover" then
        newgame()
    end
end

function printthetable()
    for i, l in ipairs(TileTable) do
        local line = ''
        for j, c in ipairs(l) do
            line = line .. c
        end
        print(line)
    end
end

-- local old_love_audio_play = love.audio.play
-- function love.audio.play(source)
--   if not source:isStopped() then
--     source:rewind()
--   else
--     old_love_audio_play(source)
--   end
-- end
