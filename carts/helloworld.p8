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
    game_over_at = 0
    last_spawn = 0
    score = 0
    ship = {
        x = 60,
        y = 100,
        sprite = 1,
        engine_sprite = 4,
        vx = 2,
        vy = 2,
        boundaries = {
          x_min = 1,
          x_max = 8,
          y_min = 1,
          y_max = 6
        }
    }
    enemies = {}
    bullets = {}
    stars = {}
    explosions = {}
    for i= 1, 64 do
      add(stars, create_star(flr(rnd(128))))
    end

    start_new_game()
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

function update_enemies() 
  for enemy in all(enemies) do
    if enemy.delete_me then
      del(enemies, enemy)
    end
  end

  if #enemies < 12 and (#enemies <= 2 or (last_spawn + 90) < ticks) then
    last_spawn = ticks
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
        boundaries = {
          x_min = 1,
          x_max = 8,
          y_min = 2,
          y_max = 6
        },
        attack_pattern = attack_pattern_alpha
      })
    end
  end

  foreach(enemies, function(enemy)
    enemy.attack_pattern(enemy)
  end)
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

function create_explosion(actor, initial_sprite)
  return {
    x = actor.x,
    y = actor.y,
    sprite = initial_sprite
  }
end

function update_game_objects()
  for explosion in all(explosions) do
    if ticks % 2 == 0 then
      explosion.sprite = explosion.sprite + 1
      if explosion.sprite < 10 then
        explosion.sprite = 10
      elseif explosion.sprite > 13 then
        del(explosions, explosion)
      end
    end
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

    for enemy in all(enemies) do
      if collision(enemy, bullet) then
        del(bullets, bullet)
        del(enemies, enemy)
        add(explosions, create_explosion(enemy, 9))
        score = score + 10
      end
    end
  end
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
  if (btn(4) or btn(5)) and ticks % 2 == 0 and #bullets < 30 then
    local bullet = {
      x = ship.x,
      y = ship.y - 2,
      vx = 0,
      vy = 0 - 4,
      sprite = 6,
      boundaries = {
        x_min = 3,
        x_max = 4,
        y_min = 2,
        y_max = 3
      }
    }
    add(bullets, bullet)
  end
end

function update_player()
  handle_player_movement()
  handle_player_fire()

  if ticks % 6 < 3 then
    ship.engine_sprite = 4
  else
    ship.engine_sprite = 5
  end

  for enemy in all(enemies) do
    if collision(ship, enemy) then
      del(enemies, enemy)
      add(explosions, create_explosion(enemy, 9))
      add(explosions, create_explosion(ship, 8))
      
      game_over()
    end
  end
end

function handle_game_over()
  if game_over_at + 30 < ticks then
    for i = 4, 5 do
      if btnp(i) then
        start_new_game()
        return
      end
    end
  end
end

function update_score()
  if ticks % 30 == 0 then
    score = score + 1
  end
end

function _update_game_over()
    ticks = ticks + 1
    update_enemies()
    update_game_objects()
    handle_game_over()
end

function _update_game_active()
    ticks = ticks + 1
    update_score()
    update_enemies()
    update_game_objects()
    update_player()
end

function draw_stars()
  for star in all(stars) do
    pset(star.x, star.y, star.colour)
  end
end

function draw_ui()
  print("score " .. score, 1, 1, 10)
end

function draw_game_objects()
  for explosion in all(explosions) do
    spr(explosion.sprite, explosion.x, explosion.y)
  end

  for enemy in all(enemies) do
    spr(enemy.sprite, enemy.x, enemy.y)
  end

  for bullet in all(bullets) do
    spr(bullet.sprite, bullet.x, bullet.y)
  end
end

function draw_player_objects()
  spr(ship.sprite, ship.x, ship.y)
  spr(ship.engine_sprite, ship.x, ship.y)
end

function _draw_game_over()  
  cls(black)

  draw_stars()
  draw_game_objects()
  draw_ui()

  print("game over", 52, 52, 12)

  print("press fire to restart", 28, 74, 12)
end

function _draw_game_active()
  cls(black)

  draw_stars()
  draw_player_objects()
  draw_game_objects()
  draw_ui()
end

function game_over()
  game_over_at = ticks
  _draw = _draw_game_over
  _update = _update_game_over
end

function start_new_game()
  score = 0
  last_spawn = ticks
  game_over_at = 0

  ship.x = 60
  ship.y = 100

  for enemy in all(enemies) do
    del(enemies, enemy)
  end

  _draw = _draw_game_active
  _update = _update_game_active
end


__gfx__
00000000000880000008800000088000000000000000000000000000000000000000000000088000000880000089980000899800000000000000000000000000
000000000087c8000087c8000087c8000000000000000000000000000076660000788600008888000089980008999980099aa990008998000000000000000000
00700700008cc800008cce0000ecc8000000000000000000000990000b3333b00b8998b00089980008999980899aa99889a00a98089009800000000000000000
0007700008888880082888e00e888280000000000000000000099000b333333bb899998b08999980899aa99899a00a999a0000a9090000900000000000000000
000770008888888882888e8888e8882800000000000000000000000038033083388998838889988808999980899aa99889a00a98089009800000000000000000
0070070088876888882768e88e876288000000000000000000000000080cc08008088080888888880089980008999980099aa990008998000000000000000000
00000000000000000000000000000000000a90000009a00000000000000cc000000cc00000000000000880000089980000899800000000000000000000000000
000000000000000000000000000000000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000
