local Map = require 'objects.obj_map'
local data = require 'maps.map_data'

Game = {}

function Game:init()
	--map = Map(data.pub, {x = 14, y = 15})
	map = Map(data.roomStart, {x = 8, y = 9})
	local music = love.audio.newSource('assets/audio/music/town.wav')
	music:setLooping(true)
	music:play()
end

function Game:enter()
end

function Game:update(dt)
	map:update(dt)
end

function Game:draw()
	map:draw()
end

function Game:keypressed(key)
	map:keypressed(key)
end