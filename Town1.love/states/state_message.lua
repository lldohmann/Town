local Map = require 'objects.obj_map'
local Box = require 'objects.obj_textBox'
Message = {}

local dialog
local object
local box

function Message:init()
end

function Message:enter()
	object = map.world:queryPoint(map.player.point.x, map.player.point.y)
	if object[1] and object[1].isNpc then
		dialog = object[1].dialog
		local direction = map.player:getFacing()
		object[1]:facePlayer(direction)
	else
		dialog = "Nothing important here..."
	end
	box = Box(16, 8, 27, 10, dialog)
end

function Message:update(dt)
	box:update(dt)
end

function Message:draw()
	map:draw()
	box:draw()
end

function Message:keypressed(key)
	if key == 'z' then
		return Gamestate.switch(Game)
	end
end