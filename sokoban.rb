require 'dispel'
require 'console_splash'
require_relative 'level'

def load_levels
  levels = []
  Dir.glob('levels/*.xsb') do | xsb_file |
    level = File.readlines(xsb_file)
    #convert level from array of strings to 2darray of chars
    level.map! do |line|
      line.chomp.chars.to_a
    end
    levels << level
  end
  levels
end

def do_splash()
  w = 0
  h = 0
  Dispel::Screen.open do |screen|
    w = screen.columns
    h = screen.lines
  end
  splash = ConsoleSplash.new(h,w)
  splash.write_header('Sokoban', 'Euan Rochester', '0.0.1')
  splash.write_horizontal_pattern('-')
  splash.write_vertical_pattern('|')
  splash.splash
end

def error(str)
  puts str
  exit 1
end

def clamp(min,max,val)
  [[val,max].min,min].max
end

def clamp_pos(min_x,min_y,max_x,max_y,pos)
  [clamp(min_y,max_y,pos[0]),
   clamp(min_x,max_x,pos[1])]
end

def in_wall(level,pos)
  level[pos[0]][pos[1]] == '#'
end

def move_player(level,pos,delta)
  new_pos = [pos[0]+delta[0],pos[1]+delta[1]]
  if in_wall(level,new_pos)
    pos
  else
    new_pos
  end
end

def main_loop(levels,screen)
  quit = false
  level_num = 0
  level = Level.new(levels[level_num])
  screen.draw *level.make_view
  Dispel::Keyboard.output do |key|
    case key
      when 'q' then break
      when :down then  level.player.move([1,0])
      when :up then level.player.move([-1,0])
      when :right then level.player.move([0,1])
      when :left then level.player.move([0,-1])
      when 'r' then level = Level.new(levels[level_num])
      when 'n'
        level_num += 1
        level = Level.new(levels[level_num])
    end
    screen.draw *level.make_view
    if level.complete?
      level_num += 1
      level = Level.new(levels[level_num])
    end
  end
end

do_splash
levels = load_levels
Dispel::Screen.open(:colors => true) do |screen|
  main_loop(levels,screen)
end