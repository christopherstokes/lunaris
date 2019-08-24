local t = 0
local s_wid = 240
local s_hei = 136
local horizon = (s_hei - 48) / 2
local Entity
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, max_dx, max_dy, acc)
      if max_dx == nil then
        max_dx = 3
      end
      if max_dy == nil then
        max_dy = 2
      end
      self.x = x
      self.y = y
      self.dx = 0
      self.dy = 0
      self.acc = acc
      self.max_dx = max_dx
      self.max_dy = max_dy
      self.alive = true
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
local Bullet
do
  local _class_0
  local _parent_0 = Entity
  local _base_0 = {
    upd = function(self)
      if math.abs(self.dy) < math.abs(self.max_dy) then
        if self.dy < 0 then
          self.dy = self.dy - self.acc
        end
        if self.dy > 0 then
          self.dy = self.dy + self.acc
        end
      end
      self.y = self.y + self.dy
      if self.y < horizon + 40 then
        self.r = 1
      end
      if self.y < horizon + 16 then
        self.r = 0
      end
      if self.y < horizon - 4 or self.y > s_hei then
        self.alive = false
      else
        if self.r == 0 then
          return pix(self.x, self.y, self.col)
        else
          return circ(self.x, self.y, self.r, self.col)
        end
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, x, y, acc, r, col, dy, max_dx, max_dy)
      if col == nil then
        col = 3
      end
      if dy == nil then
        dy = -1
      end
      if max_dx == nil then
        max_dx = 0
      end
      if max_dy == nil then
        max_dy = 2
      end
      _class_0.__parent.__init(self, x, y, max_dx, max_dy, acc)
      self.dy = dy
      self.r = r
      self.col = col
    end,
    __base = _base_0,
    __name = "Bullet",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Bullet = _class_0
end
local bullets = { }
local friction = 0.90
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
  if (t % (math.ceil(1 / terrain_lines_acc) * 2) == 0) and (terrain_lines_acc ~= 0) then
    table.insert(terrain_lines, {
      y = horizon,
      dy = 0
    })
  end
  if #terrain_lines > 0 then
    for lin = #terrain_lines, 1, -1 do
      local t_lin = terrain_lines[lin]
      local ease_lin = ease_in_quad((s_hei - t_lin.y) / (s_hei - horizon)) / 2
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
local ship = Entity(60, 104, 3, 2, 0.4)
ship.update = function(self)
  if btn(0) then
    if (terrain_lines_acc < 0.12) then
      terrain_lines_acc = terrain_lines_acc + 0.0025
    end
  end
  if btn(1) then
    if (terrain_lines_acc >= 0.02) then
      terrain_lines_acc = terrain_lines_acc - 0.0025
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
  if btnp(4) then
    table.insert(bullets, Bullet(self.x, self.y, 0.05, 2))
  end
  self.dx = self.dx * friction
  self.x = self.x + self.dx
end
ship.draw = function(self)
  local acc_mod = 0
  if self.turn_l then
    tri(self.x - 2, self.y + 2 + acc_mod, self.x - 4, self.y + 10 + acc_mod, self.x + 5, self.y + 7 + acc_mod, 1)
    tri(self.x - 2, self.y, self.x - 4, self.y + 7, self.x + 4, self.y + 4, 11)
    return tri(self.x - 1, self.y + 1, self.x - 4, self.y + 7, self.x + 4, self.y + 4, 15)
  elseif self.turn_r then
    tri(self.x + 2, self.y + 2 + acc_mod, self.x - 5, self.y + 7 + acc_mod, self.x + 4, self.y + 10 + acc_mod, 1)
    tri(self.x + 2, self.y, self.x - 4, self.y + 4, self.x + 4, self.y + 7, 11)
    return tri(self.x + 2, self.y, self.x - 4, self.y + 3, self.x + 3, self.y + 7, 15)
  else
    tri(self.x, self.y + 4 + acc_mod, self.x - 4, self.y + 11 + acc_mod, self.x + 4, self.y + 11 + acc_mod, 1)
    tri(self.x, self.y + 2, self.x - 4, self.y + 8, self.x + 4, self.y + 8, 15)
    return rect(self.x - 4, self.y + 9, 9, 1, 11)
  end
end
local planet_flight_update
planet_flight_update = function()
  cls(4)
  rect(0, horizon, s_wid, (s_hei + 48) / 2, 13)
  rect(0, horizon, s_wid, 1, 0)
  terrain_mtns_draw()
  terrain_lines_upd()
  if #bullets > 0 then
    for b = #bullets, 1, -1 do
      bullets[b]:upd()
      if not bullets[b].alive then
        table.remove(bullets, b)
      end
    end
  end
  ship:update()
  return ship:draw()
end
TIC = function()
  planet_flight_update()
  t = t + 1
end
