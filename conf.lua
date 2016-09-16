-- Game Scale
scale = 2
gameh = 22
function love.conf(t)
	t.title = "SIRTET"
	t.window.width = 12*16*scale
	t.window.height = gameh*16*scale
end