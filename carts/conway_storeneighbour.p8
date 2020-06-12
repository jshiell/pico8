pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
state = {}

neighbour_coords = {
  {x = 0 - 1, y = 0 - 1},
  {x = 0, y = 0 - 1},
  {x = 0 + 1, y = 0 - 1},
  {x = 0 - 1, y = 0},
  {x = 0 + 1, y = 0},
  {x = 0 - 1, y = 0 + 1},
  {x = 0, y = 0 + 1},
  {x = 0 + 1, y = 0 + 1},
}

function set(x, y)
  state[x][y] = (state[x][y] & 0xFE) | 0x1
  update_count_of_neighbours(x, y, 1)
end

function clear(x, y)
  state[x][y] = state[x][y] & 0xFE
  update_count_of_neighbours(x, y, -1)
end

function update_count_of_neighbours(x, y, delta)
  for neighbour in all(neighbour_coords) do
    local test_x = wrap(neighbour.x + x)
    local test_y = wrap(neighbour.y + y)
    local new_neighbours = flr(state[test_x][test_y] >>> 1) + delta
    state[test_x][test_y] = (new_neighbours << 1) | (state[test_x][test_y] & 0x1)
  end
end

function copy_state()
  local new_state = {}
  for x = 1, 128 do
    new_state[x] = {}
    for y = 1, 128 do
      new_state[x][y] = state[x][y]
    end
  end
  return new_state
end

function init_state()
  for x = 1, 128 do
    state[x] = {}
    for y = 1, 128 do
      state[x][y] = 0
    end
  end
end

function wrap(value)
  if value == nil then
    return nil
  elseif value < 1 then
    return 127
  elseif value > 127 then
    return 1
  end
  return value
end

function _init()
  init_state()

  rectfill(0, 0, 128, 128, 0)

  -- draw some starting state
  for x = 3, 24 do
    for y = 3, 24 do
      set(x, y)
    end
  end

  set(60, 60)
  set(62, 60)
  set(61, 61)
  set(62, 61)
  set(61, 62)
end

function _update()
end

function _draw()
  local read_state = copy_state()

  for y = 1, 128 do
    for x = 1, 128 do
      local current = read_state[x][y]
      if current != 0 then
        local count = flr(current >>> 1)
        if current & 0x1 == 1 then
          if count != 2 and count != 3 then
            clear(x, y)
            pset(x - 1, y - 1, 0)
          end
        else 
          if count == 3 then
            set(x, y)
            pset(x - 1, y - 1, 9)
          end
        end
      end
    end
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000