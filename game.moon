-- title:  Lunaris
-- author: Christopher Stokes (xkfngs)
-- desc:   Space Shooter/Sim heavily inspired and informed by Solaris for Atari 2600
-- script: moon

-- tools
ease_in_quad = (t) -> return t * t
ease_out_quad = (t) -> return t * (2 - t)

collides = (objA, objB) ->
	if (objA.x < objB.x + objB.wid and
		objA.x + objA.wid > objB.x and
		objA.y < objB.y + objB.hei and
		objA.y + objA.hei > objB.y)
		return true

-- globals
t=0
s_wid = 240
s_hei = 136

-- land flight
horizon = (s_hei-48)/2
clsrange = horizon+32
midrange = horizon+16
farrange = horizon+8

-- bullet distances

-- classes
class Entity
	new: (x, y, max_dx=3, max_dy=2, acc) =>
		@x = x
		@y = y
		@dx = 0
		@dy = 0
		@acc = acc
		@max_dx = max_dx
		@max_dy = max_dy
		@alive = true
		@turn_l = false
		@turn_r = false

class Bullet extends Entity
	new: (x, y, acc, r=1, col=3, dy=-1, max_dx=0, max_dy=2) =>
		super x,y,max_dx,max_dy,acc
		@dy = dy
		@r = r
		@col = col

	upd: =>
		if math.abs(@dy) < math.abs(@max_dy)
			if @dy < 0 then @dy -= @acc
			if @dy > 0 then @dy += @acc

		@y += @dy

		if @y < clsrange then @r=0.5
		if @y < midrange then @r=0

		if @y < horizon - 2 or @y > s_hei
			@alive = false
		
		else
			circ(@x, @y, @r, @col)

class Enemy extends Entity
	new: (x, y, acc, sp, col=3, dy=0, max_dx=0, max_dy=2) =>
		super x,y,max_dx,max_dy,acc
		@dy = dy
		@sp = sp
		@col = col
		@scl = 0
		@rot = 0

	upd: =>
		if math.abs(@dy) < math.abs(@max_dy)
			if @dy < 0 then @dy -= @acc
			if @dy > 0 then @dy += @acc

		@y += @dy

		@scl = 2
		if @y < clsrange then @scl = 1
		if @y < midrange then @scl = 0.5
		if @y < farrange then @scl = 0

		if @y > s_hei then @alive = false
		else
			if @scl == 0 then pix(@x, @y, @col)
			elseif @scl == 0.5 then circ(@x, @y, 2, @col)
			else 
				sclOff = (@scl*8)/2
				spr(@sp, @x-sclOff, @y-sclOff, 0, @scl, 0, @rot)

-- entity tables
bullets = {}
enemies = {}

-- flight section
friction = 0.90

terrain_lines = {}

terrain_lines_acc = 0.05

terrain_lines_upd = ->
	if (t % (math.ceil(1/terrain_lines_acc) * 2) == 0) and (terrain_lines_acc != 0)
		table.insert terrain_lines, {y: horizon, dy: 0}
	if #terrain_lines > 0
		for lin=#terrain_lines, 1, -1
			t_lin = terrain_lines[lin]
			ease_lin = ease_in_quad((s_hei-t_lin.y)/(s_hei-horizon))/2
			t_lin.dy += (terrain_lines_acc * ease_lin)
			t_lin.y += t_lin.dy
			
			if t_lin.y >= s_hei
				table.remove(terrain_lines, lin)
			else
				line 0, t_lin.y, s_wid, t_lin.y, 0

terrain_mtns = {}
terrain_mtns_generate = ->
	for x=0,s_wid,4
		rand_height = math.random(1, 8)
		mtn = {
			x: x,
			y: horizon - rand_height,
			w: 4,
			h: rand_height
		}
		table.insert terrain_mtns, mtn

terrain_mtns_draw = ->
	for m=1, #terrain_mtns
		mountain = terrain_mtns[m]
		rect(mountain.x, mountain.y, mountain.w, mountain.h, 0)

terrain_mtns_generate!

-- ship
ship = Entity 60,104,3,0,0.4

ship.update = =>
	if btn 0
		if (terrain_lines_acc < 0.15) then terrain_lines_acc += 0.0025
	if btn 1
		if (terrain_lines_acc >= 0.04) then terrain_lines_acc -= 0.0025
	if btn 2	
		@dx -= @acc
		@turn_l = true
		@turn_r = false
	if btn 3
		@dx += @acc
		@turn_r = true
		@turn_l = false
	if (not btn 2) and (not btn 3)
		@turn_r = false
		@turn_l = false

	if btnp 4
		table.insert(bullets, Bullet(@x, @y, 0.02, 1))
	
	@dx *= friction
	@x += @dx

ship.draw = =>
	-- acc_mod =  terrain_lines_acc * 20
	acc_mod = 0

	if @turn_l
		tri(@x-2, @y+2+acc_mod, @x-4, @y+10+acc_mod, @x+5, @y+7+acc_mod, 1) -- shadow
		tri(@x-2, @y, @x-4, @y+7, @x+4, @y+4, 11) -- ship
		tri(@x-1, @y+1, @x-4, @y+7, @x+4, @y+4, 15) -- ship detail
	elseif @turn_r
		tri(@x+2, @y+2+acc_mod, @x-5, @y+7+acc_mod, @x+4, @y+10+acc_mod, 1) -- shadow
		tri(@x+2, @y, @x-4, @y+4, @x+4, @y+7, 11) -- ship
		tri(@x+2, @y, @x-4, @y+3, @x+3, @y+7, 15) -- ship detail
	else
		tri(@x, @y+4+acc_mod, @x-4, @y+11+acc_mod, @x+4, @y+11+acc_mod, 1) -- shadow
		tri(@x, @y+2, @x-4, @y+8, @x+4, @y+8, 15) -- ship
		rect(@x-4, @y+9, 9, 1, 11)

-- enemy
en = Enemy(24, horizon-2, 0.001 , 1, 7, 0.5, 0, 1)
table.insert(enemies, en)

planet_flight_update = ->
	cls 4

	rect 0, horizon, s_wid, (s_hei+48)/2, 13
	rect 0, horizon, s_wid, 1, 0

	terrain_mtns_draw!
	terrain_lines_upd!

	if #enemies > 0
		for e=#enemies, 1, -1
			enemies[e]\upd!
			if not enemies[e].alive
				table.remove(enemies, e)

	if #bullets > 0
		for b=#bullets, 1, -1
			bullets[b]\upd!
			if not bullets[b].alive
				table.remove(bullets, b)
	ship\update!
	ship\draw!




export TIC=->
	planet_flight_update!
	t+=1
	
-- db16: 140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- cga16: 000000555555aaaaaaffffff0000aa5555ff00AA0055ff5500aaaa55ffffaa0000ff5555aa00aaff55ffaa5500ffff55


-- <TILES>
-- 001:0000000000766700076666700667766006000060070000700070070000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:000000555555aaaaaaffffff0000aa5555ff00aa0055ff5500aaaa55ffffaa0000ff5555aa00aaff55ffaa5500ffff55
-- </PALETTE>

