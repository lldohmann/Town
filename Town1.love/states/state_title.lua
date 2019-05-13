local TitleScreen = require 'objects.obj_title'

Title = {}

function Title:init()
	title = TitleScreen()
end

function Title:enter()
end

function Title:update(dt)
	title:update(dt)
end

function Title:draw()
	title:draw()
end

function Title:keypressed(key)
	title:keypressed(key)
end