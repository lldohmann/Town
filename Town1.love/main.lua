local Player = require 'objects/obj_player'
Gamestate = require 'libraries.gamestate'
require 'states.state_game'
require 'states.state_message'
require 'states.state_title'

function love.load()
	math.randomseed(os.time())
	love.graphics.setDefaultFilter('nearest', 'nearest')
	local font = love.graphics.newFont('assets/misc/PrStart.ttf', 8)
	love.graphics.setFont(font)
	scale = 2.0
	displayWidth, displayHeight = 256 * scale, 240 * scale
	debug = false

	love.window.setMode(displayWidth, displayHeight)

	Gamestate.registerEvents()
	Gamestate.switch(Title)
end

function love.update(dt)
end

function love.draw()
end