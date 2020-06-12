pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

state_new = {}
state_old = {}

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

function init_state(state)
  for y = 1, 128 do
    state[y] = {}
  end
end

function _init()
  init_state(state_new)
  init_state(state_old)

  for y = 13, 34 do
    for x = 13, 34 do 
      set(x, y, state_old)
    end
  end

  for y = 53, 54 do
    for x = 53, 54 do 
      set(x, y, state_old)
    end
  end

  set(80, 80, state_old)
  set(80, 82, state_old)
  set(81, 81, state_old)
  set(81, 82, state_old)
  set(82, 81, state_old)
end

function set(x, y, table)
  if not contains_x(x, table[y]) then
    table[y][#(table[y]) + 1] = x
  end
end

function contains_x(x, table)
  if x < 0 or x > 127 then
    return false
  end

  for value in all(table) do
    if value == x then
      return true
    end
  end
  return false
end

function _update()
  for y = 1, 128 do
    for x in all(state_old[y]) do
      eval_neighbours_of_live(x, y)
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

function eval_neighbours_of_live(x, y)
  local count = 0

  for neighbour in all(neighbour_coords) do
    local test_x = wrap(neighbour.x + x)
    local test_y = wrap(neighbour.y + y)

    if count < 4 and contains_x(test_x, state_old[test_y]) then
      count += 1
    end
    
    if not contains_x(test_x, state_old[test_y]) then
      eval_neighbours_of_dead(test_x, test_y)
    end
  end

  if count == 2 or count == 3 then
    set(x, y, state_new)
  end
end

function eval_neighbours_of_dead(x, y)
  local count = 0

  for neighbour in all(neighbour_coords) do
    local test_x = wrap(neighbour.x + x)
    local test_y = wrap(neighbour.y + y)
    if count < 4 and contains_x(test_x, state_old[test_y]) then
      count +=1
    end
  end

  if count == 3 then
    set(x, y, state_new)
  end
end

function _draw()
  rectfill(0, 0, 128, 128, 0)
  for y = 1, 128 do
    for x in all(state_new[y]) do
      pset(x - 1, y - 1, 9)
    end
  end

  local swap_state = state_old
  state_old = state_new
  state_new = swap_state
  init_state(state_new)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000