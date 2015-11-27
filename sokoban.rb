require 'dispel'
require 'console_splash'

def load_levels
  levels = []
  Dir.glob('levels/*.xsb') do | xsb_file |
    level = File.readlines(xsb_file)
    #convert level from array of strings to 2darray of chars
    level.map! do |line|
      line.chars.to_a
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

def get_start_pos(level)
  level.each_with_index  do |line,y|
    line.each_with_index  do |char,x|
      if char == '@'
        return [y,x]
      end
    end
  end
  error('level is missing a player start pos!')
end

def make_view(buffer)
  (buffer.map do |buff_line|
    buff_line.join('')
  end).join("\n")
end

def draw_level(screen,level,width,height,player_pos)
  buff = Array.new(height) { Array.new(width) }
  level.each_with_index  do |line,y|
    buff[y] = []
    line.each_with_index  do |char,x|
      if char != '@' && char != "\n"
        buff[y][x] = char
      else
        buff[y][x] = ' '
      end
    end
  end
  buff[player_pos[0]][player_pos[1]] = '@'
  screen.draw(make_view(buff))
end

def get_level_size(level)
  width = level.length
  height = 0
  level.each_with_index  do |line,y|
    height = [height,line.length].max
  end
  [width,height]
end

def clamp(min,max,val)
  [[val,max].min,min].max
end

def clamp_pos(min_x,min_y,max_x,max_y,pos)
  [clamp(min_y,max_y,pos[0]),
   clamp(min_x,max_x,pos[1])]
end

def move_player(level,pos,delta)

end

def main_loop(levels,screen)
  quit = false
  level = 0
  player_pos = get_start_pos(levels[level])
  (width,height) = get_level_size(levels[level])
  draw_level(screen,levels[level],width,height,player_pos)
  Dispel::Keyboard.output do |key|
   case key
     when 'q' then break
     when :down then player_pos[0]+=1
     when :up then player_pos[0]-=1
     when :right then player_pos[1]+=1
     when :left then player_pos[1]-=1
   end
   player_pos = clamp_pos(0,0,width,height,player_pos)
   draw_level(screen,levels[level],width,height,player_pos)
  end
end

do_splash
levels = load_levels
Dispel::Screen.open do |screen|
  main_loop(levels,screen)
end