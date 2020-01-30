--[[
Flappy Bird remake
]]

-- push is a library that allows us to draw our game at a
-- virtual resolution
push = require 'push'
-- classic OOP class library
Class = require 'class'
-- classes we've written, for game state and state machines
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'
-- classes we've written
require 'Bird'
require 'Pipe'
require 'PipePair'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
-- size we're trying to emulate with push
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288
-- background image and starting scroll location (x axis)
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0
-- ground image and starting scroll location (X axis)
local ground = love.graphics.newImage('ground.png')
local groundScroll = 0
-- speed at which we should scroll our images, scaled by dt
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60
-- point at which we should loop our background back to X 0
local BACKGROUND_LOOPING_POINT = 413
-- scrolling variable to pause the game when we collide with a pipe
local scrolling = true

function love.load()
    -- set love's default filter to 'nearest neighbor', which means
    -- there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2d look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG
    math.randomseed(os.time())

    -- set title of window
    love.window.setTitle('Fifty Bird')

    -- init our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- initialize our table of sounds
    sounds = {
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        -- https://freesound.org/people/xsgianni/sounds/388079
        ['music'] = love.audio.newSource('marios_way.mp3', 'static'),
    }
    -- kickoff music
    sounds['music']:setLooping(true)
    sounds['music']:play()

    -- init our virtual resolution, which will be rendered within
    -- our actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
    }
    gStateMachine:change('title')

    -- init input table
    love.keyboard.keysPressed = {}
    -- init mouse input table
    love.mouse.buttonsPressed = {}
end

--[[
    Called when the dimensions of the window is changed, as by dragging
    out its bottom corner.  In this case, we need to worry about only
    calling to 'push' to handle the resizing.
    w - width, h - height
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (love.keyboard.isDown).  Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- 'key' will be whatever key this callback detected as pressed
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        -- the function LOVE2D uses to quit the application
            love.event.quit()
    end
end

--[[
    Love2D callback fired each time a mouse button is pressed; give us
    the X and Y coord of the mouse, as well as the button in question
]]
function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

--[[
    New function used to check our global input table for keys we
    activated during this frame, looked up by their string value.
]]
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    if scrolling then
        -- scroll background by preset speed * dt, looping back to 0 after the looping point
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        -- scroll ground by preset speed * dt, looping back to 0 after the looping point
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end
    -- now, we just update the state machine, which defers to the right state
    gStateMachine:update(dt)
    -- reset input tables
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

--[[
    Called after each frame update.  Is responsible simply for drawing
    all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:start()

    -- draw the background starting at the negative looping point
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    -- draw the ground on top of the background, toward the bottom of the screen,
    -- at its negative looping pint
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    -- end our drawing to push
    push:finish()
end
