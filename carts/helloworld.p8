pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function create_star(y)
  local speed = flr(rnd(3))
  local colour = 7
  if speed < 2 then
    colour = 6
  end

  return {
    x = flr(rnd(128)),
    y = y,
    vy = flr(rnd(2)) + 1,
    colour = colour
  }
end

function _init()
    ticks = 0
    ship = {
        x = 60,
        y = 100,
        sprite = 1,
        engine_sprite = 4,
        vx = 2,
        vy = 2
    }
    enemies = {}
    bullets = {}
    stars = {}
    for i= 1, 64 do
      add(stars, create_star(flr(rnd(128))))
    end
end

function attack_pattern_alpha(actor) 
  actor.r = actor.r or 15
  actor.time = (actor.time or 0) + 1
  actor.x = (actor.r * sin(actor.time / 64)) + actor.ax + (actor.vx * actor.time / 2)
  actor.y = (actor.r * cos(actor.time / 64)) + actor.ay + (actor.vy * actor.time / 2)

  if (actor.x < -32 and actor.vx < 0) 
      or (actor.x > 160 and actor.vx > 0) 
      or (actor.y < -32 and actor.vy < 0)
      or (actor.y > 160 and actor.vy > 0) then
    actor.delete_me = true
  end
end

function handle_enemies() 
  for enemy in all(enemies) do
    if enemy.delete_me then
      del(enemies, enemy)
    end
  end

  if #enemies <= 0 then
    local spawn_location = flr(rnd(4))
    local spawn_axis = flr(rnd(100)) + 16
    local offsets, x, y, vx, vy
    if spawn_location == 1 then
      x = -8
      y = spawn_axis
      vx = 1
      vy = 0
      offsets = function(index)
        return 16 - (16 * index), 0
      end
    elseif spawn_location == 2 then
      x = spawn_axis
      y = -8
      vx = 0
      vy = 1
      offsets = function(index)
        return 0, 16 - (16 * index)
      end
    else 
      x = 128
      y = spawn_axis
      vx = -1
      vy = 0
      offsets = function(index)
        return (16 * index ) - 16, 0
      end
    end

    for i = 1, 4 do
      local x_offset, y_offset = offsets(i)
      add(enemies, {
        ax = x + x_offset,
        ay = y + y_offset,
        vx = vx,
        vy = vy,
        sprite = 7,
        attack_pattern = attack_pattern_alpha
      })
    end
  end

  foreach(enemies, function(enemy)
    enemy.attack_pattern(enemy)
  end)
end

function handle_player_movement()
  if btn(0) and ship.x > 0 then
    ship.x = ship.x - ship.vx
    ship.sprite = 2
  elseif btn(1) and ship.x < 120 then
    ship.x = ship.x + ship.vx
    ship.sprite = 3
  else
    ship.sprite = 1
  end

  if btn(2) and ship.y > 0 then
    ship.y = ship.y - ship.vy
  elseif btn(3) and ship.y < 120 then
    ship.y = ship.y + ship.vy
  end
end

function handle_player_fire()
  if btn(4) and ticks % 2 == 0 and #bullets < 30 then
    local bullet = {
      x = ship.x,
      y = ship.y - 2,
      vx = 0,
      vy = 0 - 4,
      sprite = 6,
      boundaries = {
      }
    }
    add(bullets, bullet)
  end
end

function collision(first_actor, second_actor)
  if (first_actor.x + first_actor.boundaries.x_min) > (second_actor.x + second_actor.boundaries.x_max)
      or (first_actor.y + first_actor.boundaries.y_min) > (second_actor.y + second_actor.boundaries.y_max)
      or (second_actor.x + second_actor.boundaries.x_min) > (first_actor.x + first_actor.boundaries.x_max)
      or (second_actor.y + second_actor.boundaries.y_min) > (first_actor.y + first_actor.boundaries.y_max) then
    return false
  end
  return true
end

function update_state()
  if ticks % 6 < 3 then
    ship.engine_sprite = 4
  else
    ship.engine_sprite = 5
  end

  for star in all(stars) do
    star.y = star.y + star.vy
    if star.y > 128 then
      del(stars, star)
      add(stars, create_star(0))
    end
  end

  for bullet in all(bullets) do
    bullet.x = bullet.x + bullet.vx
    bullet.y = bullet.y + bullet.vy
    if bullet.x < -8 or bullet.x > 128 or bullet.y < -8 or bullet.y > 128 then
      del(bullets, bullet)
    end
  end
end

function _update()
    ticks = ticks + 1
    handle_enemies()
    handle_player_movement()
    handle_player_fire()
    update_state()
end

function _draw()
    cls(black)
    for star in all(stars) do
      pset(star.x, star.y, star.colour)
    end

    spr(ship.sprite, ship.x, ship.y)
    spr(ship.engine_sprite, ship.x, ship.y)

    for enemy in all(enemies) do
      spr(enemy.sprite, enemy.x, enemy.y)
    end

    for bullet in all(bullets) do
      spr(bullet.sprite, bullet.x, bullet.y)
    end
end

__gfx__
00000000000880000008800000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000087c8000087c8000087c800000000000000000000000000007666000000000000000000000000000000000000000000000000000000000000000000
00700700008cc800008cce0000ecc8000000000000000000000990000b3333b00000000000000000000000000000000000000000000000000000000000000000
0007700008888880082888e00e888280000000000000000000099000b333333b0000000000000000000000000000000000000000000000000000000000000000
000770008888888882888e8888e88828000000000000000000000000380330830000000000000000000000000000000000000000000000000000000000000000
0070070088876888882768e88e876288000000000000000000000000080cc0800000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000a90000009a00000000000000cc0000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000
