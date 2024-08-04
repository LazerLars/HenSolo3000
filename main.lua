if arg[2] == "debug" then
    require("lldebugger").start()
end

    -- recommended screen sizes
---+--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | scale factor | desktop res | 1    | 2   | 3   | 4   | 5   | 6   | 8   | 10  |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
-- | width        | 1920        | 1920 | 960 | 640 | 480 | 384 | 320 | 240 | 192 |
-- | height       | 1080        | 1080 | 540 | 360 | 270 | 216 | 180 | 135 | 108 |
-- +--------------+-------------+------+-----+-----+-----+-----+-----+-----+-----+
local settings = {
    fullscreen = false,
    screenScaler = 2,
    logicalWidth = 192,
    logicalHeight = 360,
    background_color =  {
        r = 131,
        g = 118,
        b = 156
    }
}
-- global mouse variables to hold correct mouse pos in the scaled world 
mouse_x, mouse_y = ...

spriteSheet = love.graphics.newImage("sprites/spriteSheet.png")
spriteCordinates = {
    chickenNest = {
        col = 1,
        row = 1
    },
    egg =  {
        col = 1,
        row = 2
    }
}

gameSettings = {
    speed = 50
}
timerLeft = 0
counterLeft = 0
intervalLeft = 0.9

timerRight = 0
counterRight = 0
intervalRight = 0.9

gameObjs = {}

function love.load()
    love.window.setTitle( 'inLove2D' )
    spriteSheet:setFilter("nearest", "nearest")

    -- sprChickenNest = loadSprite(spriteCordinates.chickenNest.col, spriteCordinates.chickenNest.row)

    -- Set up the window with resizable option
    love.window.setMode(settings.logicalWidth, settings.logicalHeight, {resizable=true, vsync=0, minwidth=settings.logicalWidth*settings.screenScaler, minheight=settings.logicalHeight*settings.screenScaler})
    -- font = love.graphics.newFont('fonts/m6x11.ttf', 16)
    -- font = love.graphics.newFont('fonts/PressStart2P-Regular.ttf', 16)
    -- https://ggbot.itch.io/pixeloid-font
    -- pixeloid sizes: 9, 18, 36, 72, 144
    font = love.graphics.newFont('fonts/PixeloidMono.ttf', 9)
    
    
    love.graphics.setFont(font)
    -- love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor( settings.background_color.r/255, settings.background_color.g/255, settings.background_color.b/255)
end

-- y = 1
function love.update(dt)
    -- Get the current window size
    calculateMouseOffsets()

    timerLeft = timerLeft + dt
    timerRight = timerRight + dt
-- print every time 1 sec has gone
    if timerLeft >= intervalLeft then
        timerLeft = 0
        print('1 sec has passsed')
        counterLeft = counterLeft + 1
        print (counterLeft)
        makeNest(20)
    end

    if timerRight >= intervalRight then
        timerRight = 0
        print('1 sec has passsed')
        counterRight = counterRight + 1
        print (counterRight)
        makeNest(140)
    end
    -- y = y + 30 * dt
    -- gameSettings.speed = gameSettings.speed + 0.05
    for index, value in ipairs(gameObjs) do
        if value.type == "nest" then            
            value.y = value.y + gameSettings.speed * dt
        end
        if value.type == "egg" then            
            value.x = value.x + value.dir * 400 * dt
        end
    end
end


function love.draw()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    -- game draw logic here
    -- print mouse cordinates
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print("mouse: " .. mouse_x .. "," .. mouse_y, 1, 1)
    font = love.graphics.newFont('fonts/PixeloidMono.ttf', 18)
    love.graphics.setFont(font)
    for index, value in ipairs(gameObjs) do
        if value.type == "nest" then            
            love.graphics.draw(spriteSheet, value.spr, value.x,value.y)
        end
        if value.type == "egg" then
            love.graphics.draw(spriteSheet, value.spr, value.x, value.y)
        end
    end
    love.graphics.pop()
end

-- adjust mouse cordinates to match the scaling done in the game
function calculateMouseOffsets()
    -- Get the current window size
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Calculate the current scaling factor
    scaleX = windowWidth / settings.logicalWidth
    scaleY = windowHeight / settings.logicalHeight
    scale = math.min(scaleX, scaleY)

    -- Calculate the offsets to center the game
    offsetX = (windowWidth - settings.logicalWidth * scale) / 2
    offsetY = (windowHeight - settings.logicalHeight * scale) / 2

    -- Adjust mouse coordinates
    mouse_x, mouse_y = love.mouse.getPosition()
    mouse_x = (mouse_x - offsetX) / scale
    mouse_y = (mouse_y - offsetY) / scale
    mouse_x = math.floor(mouse_x)
    mouse_y = math.floor(mouse_y)
end

function love.keypressed(key)
    -- toggle fullscreen
    if key == 'f11' then
        if settings.fullscreen == false then
            love.window.setFullscreen(true, "desktop")
            settings.fullscreen = true
        else
            love.window.setMode(settings.logicalWidth, settings.logicalHeight, {resizable=true, vsync=0, minwidth=settings.logicalWidth*settings.screenScaler, minheight=settings.logicalHeight*settings.screenScaler})
            settings.fullscreen = false
        end 
    end
    if key == 'n' then
        makeNest((settings.logicalWidth/2)-100)
        makeNest((settings.logicalWidth/2)+100)
        
    end
    if key == 'x' then
        makeEgg(1)
    end
    if key == 'z' then
        makeEgg(-1)
    end
end

function sampleDrawCode()
    -- Draw the game elements
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", circle.x, circle.y, circle.radius)
    love.graphics.setColor(0.2, 0.8, 0.2)
    

    -- Draw vertical line
    love.graphics.line(circle.x, circle.y, mouse_x, circle.y)
    -- Draw horizontal line
    love.graphics.line(circle.x, circle.y, circle.x, mouse_y)
    -- Draw kune tiwards the mouse
    love.graphics.line(circle.x, circle.y, mouse_x, mouse_y)

    love.graphics.rectangle('line', settings.logicalWidth/2, settings.logicalHeight/2, 16,16)
end


function loadSprite(colNumb, rowNumb)
    -- Each sprite is 16x16
    local spriteWidth = 16
    local spriteHeight = 16

    -- Calculate the position of the sprite in the sprite sheet
    local x = (colNumb - 1) * spriteWidth
    local y = (rowNumb - 1) * spriteHeight

    -- Create a quad for the sprite
    local quad = love.graphics.newQuad(x, y, spriteWidth, spriteHeight, spriteSheet:getDimensions())

    return quad
end

function makeNest(x)
    local nest = {
        type = "nest",
        spr = loadSprite(spriteCordinates.chickenNest.col, spriteCordinates.chickenNest.row),
        x = x,
        y = 1
    }
    table.insert(gameObjs, nest)
end

function makeEgg(dir)
    local egg = {
        type = "egg",
        spr = loadSprite(spriteCordinates.egg.col, spriteCordinates.egg.row),
        x = settings.logicalWidth/2,
        y = 300,
        dir = dir
    }
    table.insert(gameObjs, egg)
    print("Making egg")
end

