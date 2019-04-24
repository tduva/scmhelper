
local function createCuboid(x1, y1, z1, x2, y2, z2)
	x1 = tonumber(x1)
	y1 = tonumber(y1)
	z1 = tonumber(z1)
	x2 = tonumber(x2)
	y2 = tonumber(y2)
	z2 = tonumber(z2)

	local x = x1
	if (x2 < x1) then
		x = x2
	end
	local y = y1
	if (y2 < y1) then
		y = y2
		
	end
	local z = z1
	if (z2 < z1) then
		z = z2
	end

	local width = math.abs(x2 - x1)
	local depth = math.abs(y2 - y1)
	local height = math.abs(z2 - z1)

	return createColCuboid(x, y, z, width, depth, height)
end

local function createCircle(x,y,z,r)
	local x = tonumber(x)
	local y = tonumber(y)
	local z = tonumber(z)
	local r = tonumber(r)
	return createColCircle(x, y, r)
end

local function createRadiusRectangle(x,y,rx,ry)
	local x = tonumber(x)
	local y = tonumber(y)
	local rx = tonumber(rx)
	local ry = tonumber(ry)
	return createColRectangle(x - rx, y - ry, rx*2, ry*2)
end

local function createRadiusCuboid(x, y, z, rx, ry, rz)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	rx = tonumber(rx)
	ry = tonumber(ry)
	rz = tonumber(rz)
	return createColCuboid(x - rx, y - ry, z - rz, rx*2, ry*2, rz*2)
end

-- A rectangle that extends h distance from the line between (x1, y1) and (x2, y2),
-- so differently from many other functions this rectangle can be tilted relative to
-- the coordinate system.
local function createAngledRectangle(x1, y1, x2, y2, h)
	x1 = tonumber(x1)
	y1 = tonumber(y1)
	x2 = tonumber(x2)
	y2 = tonumber(y2)
	h = tonumber(h)

	local vx = -(y2 - y1)
	local vy = (x2 - x1)
	local l = math.sqrt(vx*vx + vy*vy)
	vx = (vx / l) * h
	vy = (vy / l) * h

	local x3 = vx + x2
	local y3 = vy + y2
	local x4 = vx + x1
	local y4 = vy + y1

	return createColPolygon(x1,y1, x1, y1, x2, y2, x3, y3, x4, y4)
end

-- Stuff that was collected from several lines under a section, like several coordinate assignments
local function parseSection(code)
	local check = string.match(code, "COORDINATES:([%d%.- ]+)$")
	if check ~= nil then
		local coords = check:split(" ")
		local x = tonumber(coords[1])
		local y = tonumber(coords[2])
		local z = tonumber(coords[3])
		return createMarker(x, y, z)
	end
	return false
end

opcodesDef = {"00A4:","00FE:","0395:","00FF:","01A6:","8100:","81AC:","80FE:","00B0:","03BA:","00EC:", "05F6:"}

function createMarkerForCode(code)
	local arg = code:split(" ")
	local opcode = arg[1]
	
	if opcode == "0395:" then
		-- https://gtagmodding.com/opcode-database/opcode/0395/
		--
		-- The height might actually not have any affect?
		--
		-- 0395: clear_area 1 at -1944.025 135.5236 24.7109 radius 100.0 
		-- 
		-- Tested ingame:
		-- 0395: clear_area 1 at 2287.0 -1292.975 12 radius 25.0 (screenshot)
		-- 0395: clear_area 1 at 2287.0 -1292.975 12.0 radius 25.0 
		-- 0395: clear_area 1 at 2287.0 -1292.975 120.0 radius 25.0
		-- (All of these, with just the height different, seemed to work the same)
		--
		return createCircle(arg[5], arg[6], arg[7], arg[9])

	elseif opcode == "00FE:" or opcode == "00FF:" then
		-- https://gtagmodding.com/opcode-database/opcode/00FE/
		--
		-- sphere 0 = No marker
		-- 00FE:   actor $PLAYER_ACTOR sphere 0 in_sphere 812.4495 -1343.488 12.532 radius 80.0 80.0 20.0
		-- 00FF:   actor 40@ sphere 0 in_sphere -779.844 499.811 1367.571 radius 0.75 0.75 2.0 on_foot 
		--
		-- Tested ingame:
		-- 00FE:   actor $PLAYER_ACTOR sphere 0 in_sphere 2287.0 -1292.975 12.532 radius 80.0 80.0 14.0
		-- 00FE:   actor $PLAYER_ACTOR sphere 0 in_sphere 2287.0 -1292.975 12.532 radius 80.0 40.0 14.0 (screenshot)
		-- 00FF:   actor $PLAYER_ACTOR sphere 0 in_sphere 2287.0 -1292.975 22.832 radius 50.0 10.0 2.0 on_foot (screenshot)
		-- 00FF:   actor $PLAYER_ACTOR sphere 0 in_sphere 2287.0 -1292.975 27.832 radius 50.0 10.0 2.0 on_foot (screenshot)
		-- Some others I didn't note down
		--
		return createRadiusCuboid(arg[7], arg[8], arg[9], arg[11], arg[12], arg[13])

	elseif opcode == "80FE:" then
		-- 80FE:   not actor $PLAYER_ACTOR sphere 0 in_sphere $X_STUNT_MISSION_NRG500 $Y_STUNT_MISSION_NRG500 $Z_STUNT_MISSION_NRG500 radius 4.0 4.0 3.0 
		--
		-- Tested ingame:
		-- 80FE:   not actor $PLAYER_ACTOR sphere 1 in_sphere 2287.0 -1292.975 12.532 radius 20.0 4.0 30.0 (screenshot)
		--
		return createRadiusCuboid(arg[8], arg[9], arg[10], arg[12], arg[13], arg[14])
	
	elseif opcode == "8100:" then
		-- Probably the same in regards to location as 00FE
		--
		-- 8100:   not actor $PLAYER_ACTOR in_sphere 7500.0 2478.34 200.0 radius 100.0 100.0 200.0 sphere 0 in_car 
		-- 8100:   not actor $PLAYER_ACTOR in_sphere 2287.0 -1292.975 12.532 radius 100.0 10.0 12.0 sphere 0 in_car (screenshot)
		--
		return createRadiusCuboid(arg[6], arg[7], arg[8], arg[10], arg[11], arg[12])

	elseif opcode == "00EC:" then
		-- https://gtagmodding.com/opcode-database/opcode/00EC/
		--
		-- 1 = marker
		--
		-- Tested ingame:
		-- 00EC:   actor $PLAYER_ACTOR 1 near_point 2287.0 -1292.975 radius 40.0 10.0 
		-- 00EC:   actor $PLAYER_ACTOR 0 near_point 2217.0 -1292.975 radius 5.0 100.0 (screenshot)
		--
		return createRadiusRectangle(arg[6], arg[7], arg[9], arg[10])

	elseif opcode == "05F6:" then
		-- https://gtagmodding.com/opcode-database/opcode/05F6/
		--
		-- flag 1 = marker
		--
		-- Tested ingame:
		-- 05F6:   actor $PLAYER_ACTOR in_rectangle_ll_corner_at 2287.0 -1292.975 lr_corner_at 2237.0 -1300.975 height 82.0 flag 0 
		-- 05F6:   actor $PLAYER_ACTOR in_rectangle_ll_corner_at 2237.0 -1292.975 lr_corner_at 2287.0 -1300.975 height 20.0 flag 0 
		-- 05F6:   actor $PLAYER_ACTOR in_rectangle_ll_corner_at 2237.0 -1300.975 lr_corner_at 2287.0 -1292.975 height 82.0 flag 0 
		-- 05F6:   actor $PLAYER_ACTOR in_rectangle_ll_corner_at 2237.0 -1300.975 lr_corner_at 2217.0 -1292.975 height 12.0 flag 1 (screenshot)
		--
		return createAngledRectangle(arg[5], arg[6], arg[8], arg[9], arg[11])

	elseif opcode == "00A4:" or opcode == "01A6:" then
		-- https://gtagmodding.com/opcode-database/opcode/00A4/
		--
		-- 00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 685.9716 -1433.523 11.0857 cornerB 965.9512 -1379.386 14.9731
		-- 01A6:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA -777.827 510.0 1369.0 cornerB -797.0 494.0 1373.0 on_foot 
		--
		-- Tested ingame:
		-- 00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 2287.0 -1299.975 26.0857 cornerB 2325.0 -1230.153 22.9731
		-- 00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 2287.0 -1299.975 22.0857 cornerB 2325.0 -1230.153 26.9731
		-- 00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 2325.0 -1299.975 22.0857 cornerB 2287.0 -1230.153 26.9731
		-- 00A4:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 2287.0 -1305.975 26.0857 cornerB 2325.0 -1230.153 22.9731 (screenshot)
		-- 01A6:   actor $PLAYER_ACTOR sphere 0 in_cube_cornerA 2287.0 -1299.975 26.0857 cornerB 2325.0 -1230.153 22.9731 on_foot (screenshot)
		--
		return createCuboid(arg[7], arg[8], arg[9], arg[11], arg[12], arg[13])
	
	elseif opcode == "81AC:" then
		-- 81AC:   not car 112@ sphere 0 in_cube_cornerA 1636.319 1144.478 7.0 cornerB 1261.411 1780.672 14.0 stopped 
		--
		-- Tested ingame:
		-- 81AC:   not car $60 sphere 0 in_cube_cornerA 2287.0 -1292.975 32.532 cornerB 2227.0 -1282.975 12.532 stopped (screenshot)
		return createCuboid(arg[8], arg[9], arg[10], arg[12], arg[13], arg[14])

	elseif opcode == "00B0:" then
		-- https://gtagmodding.com/opcode-database/opcode/00B0/
		--
		-- 00B0:   car 316@ sphere 0 in_rectangle_cornerA 960.4431 2087.975 cornerB 996.5055 2182.153 
		--
		-- Tested ingame:
		-- 00B0:   car $60 sphere 0 in_rectangle_cornerA 2287.0 -1292.975 cornerB 2297.0 -1230.153
		-- 00B0:   car $60 sphere 0 in_rectangle_cornerA 2287.0 -1292.975 cornerB 2297.0 -1299.153
		-- 00B0:   car $60 sphere 0 in_rectangle_cornerA 2237.0 -1292.975 cornerB 2297.0 -1299.153
		-- 00B0:   car $60 sphere 0 in_rectangle_cornerA 2297.0 -1292.975 cornerB 2247.0 -1299.153 (screenshot)
		--
		return createCuboid(arg[7], arg[8], 0, arg[10], arg[11], 1000)

	elseif opcode == "03BA:" then
		-- https://gtagmodding.com/opcode-database/opcode/03BA/
		--
		-- 03BA: clear_cars_from_cube_cornerA -1328.999 1239.997 -5.0 cornerB -1655.868 1638.755 10.0
		--
		-- Tested ingame:
		-- 03BA: clear_cars_from_cube_cornerA 2287.0 -1299.975 26.0857 cornerB 2325.0 -1180.153 22.9731 (screenshot)
		-- 
		return createCuboid(arg[3],arg[4],arg[5],arg[7],arg[8],arg[9])

	elseif opcode ~= nil and opcode:starts(":") then
		return parseSection(code)
	end

	return false
end

-- "Tested ingame" means the same code snippet was build into the main.scm using SannyBuilder in order to
-- then move around ingame to see if a text appears when inside the trigger area visualized by this script.
--
-- Some notes:
-- * $60 was used because it refers to the bike at the start of the game
-- * It's important to specify a floating point number ("50" doesn't seem to work, but "50.0" does)
-- * For some a screenshot has been saved in order to be able to roughly compare the visualization in case
--   changes to the script have been made (to catch any obvious errors like switched parameters)
