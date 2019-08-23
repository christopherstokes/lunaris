local t = 0
local s_wid = 240
local s_hei = 136
local Entity
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, max_dx, max_dy, acc)
      self.x = x
      self.y = y
      self.dx = 0
      self.dy = 0
      self.acc = acc
      self.max_dx = max_dx
      self.max_dy = max_dy
      self.turn_l = false
      self.turn_r = false
    end,
    __base = _base_0,
    __name = "Entity"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Entity = _class_0
end
local friction = 0.90
local horizon = (s_hei - 48) / 2
local terrain_lines = { }
local terrain_lines_acc = 0.05
local ease_in_quad
ease_in_quad = function(t)
  return t * t
end
local ease_out_quad
ease_out_quad = function(t)
  return t * (2 - t)
end
local terrain_lines_upd
terrain_lines_upd = function()
  if t % math.floor(15 - (terrain_lines_acc * 50)) == 0 then
    table.insert(terrain_lines, {
      y = horizon,
      dy = 0
    })
  end
  if #terrain_lines > 0 then
    for lin = #terrain_lines, 1, -1 do
      local t_lin = terrain_lines[lin]
      local ease_lin = ease_in_quad((s_hei - t_lin.y) / (s_hei - horizon))
      t_lin.dy = t_lin.dy + (terrain_lines_acc * ease_lin)
      t_lin.y = t_lin.y + t_lin.dy
      if t_lin.y >= s_hei then
        table.remove(terrain_lines, lin)
      else
        line(0, t_lin.y, s_wid, t_lin.y, 0)
      end
    end
  end
end
local terrain_mtns = { }
local terrain_mtns_generate
terrain_mtns_generate = function()
  for x = 0, s_wid, 4 do
    local rand_height = math.random(1, 8)
    local mtn = {
      x = x,
      y = horizon - rand_height,
      w = 4,
      h = rand_height
    }
    table.insert(terrain_mtns, mtn)
  end
end
local terrain_mtns_draw
terrain_mtns_draw = function()
  for m = 1, #terrain_mtns do
    local mountain = terrain_mtns[m]
    rect(mountain.x, mountain.y, mountain.w, mountain.h, 0)
  end
end
terrain_mtns_generate()
local ship = Entity(60, 116, 3, 2, 0.4)
ship.update = function(self)
  if btn(0) then
    if (terrain_lines_acc < 0.07) then
      terrain_lines_acc = terrain_lines_acc + 0.01
    end
  end
  if btn(1) then
    if (terrain_lines_acc > 0.03) then
      terrain_lines_acc = terrain_lines_acc - 0.01
    end
  end
  if btn(2) then
    self.dx = self.dx - self.acc
    self.turn_l = true
    self.turn_r = false
  end
  if btn(3) then
    self.dx = self.dx + self.acc
    self.turn_r = true
    self.turn_l = false
  end
  if (not btn(2)) and (not btn(3)) then
    self.turn_r = false
    self.turn_l = false
  end
  self.dx = self.dx * friction
  self.x = self.x + self.dx
end
ship.draw = function(self)
  if self.turn_l then
    return tri(self.x - 2, self.y, self.x - 4, self.y + 8, self.x + 4, self.y + 4, 14)
  elseif self.turn_r then
    return tri(self.x + 2, self.y, self.x - 4, self.y + 4, self.x + 4, self.y + 8, 14)
  else
    return tri(self.x, self.y + 2, self.x - 4, self.y + 8, self.x + 4, self.y + 8, 14)
  end
end
TIC = function()
  cls(2)
  rect(0, horizon, s_wid, (s_hei + 48) / 2, 13)
  rect(0, horizon, s_wid, 1, 0)
  terrain_mtns_draw()
  terrain_lines_upd()
  ship:update()
  ship:draw()
  t = t + 1
end
