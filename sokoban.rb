require 'dispel'
require 'console_splash'
require_relative 'level'

def get_levelnum_from_file(filename)
  match = /levels\/level(\d+)\.xsb/.match(filename)[1].to_i
end

def load_levels
  levels = []
  Dir.glob('levels/*.xsb') do | xsb_file |
    level = File.readlines(xsb_file)
    #convert level from array of strings to 2darray of chars
    level.map! do |line|
      line.chomp.chars.to_a
    end
    #need to get number as glob gives us files is lexicographical order, not numerical
    levels[get_levelnum_from_file(xsb_file)-1] = level
  end
  levels
end

def mk_splash
  splash = ConsoleSplash.new(25,80)
  splash.write_header('Sokoban', 'Euan Rochester', '0.0.1',{:nameFg=>:yellow,:nameBg=>:black,
                                                            :authorFg=>:yellow,:authorBg=>:black,
                                                            :versionFg=>:magenta,:versionBg=>:black})
  splash.write_horizontal_pattern('-',{:fg=>:yellow,:bg=>:black})
  splash.write_vertical_pattern('|',{:fg=>:yellow,:bg=>:black})
  splash
end

def mk_win_splash
  splash = mk_splash
  splash.write_center(-8, 'You Win!')
  splash
end

def make_empty_buffer(screen)
  Array.new(screen.lines){Array.new(screen.columns){' '}}
end

def append_status_line(view,level_num,total_levels)
  (buff,map) = view
  buff[-1] = "level_num #{level_num}/#{total_levels}"
  [buff.join("\n"),map]
end

def main_loop(levels,screen)
  level_num = 0
  level = Level.new(levels[level_num])
  screen.draw *append_status_line(level.make_view(make_empty_buffer(screen)),level_num+1,levels.length)
  Dispel::Keyboard.output do |key|
    case key
      when 'q' then break
      when :down then  level.player.move([1,0])
      when :up then level.player.move([-1,0])
      when :right then level.player.move([0,1])
      when :left then level.player.move([0,-1])
      when 'r' then level = Level.new(levels[level_num])
    end
    if level.complete?
      level_num += 1
      if level_num >= levels.length
        puts "level_num #{level_num}"
        break
      end
      level = Level.new(levels[level_num])
    end
    screen.draw *append_status_line(level.make_view(make_empty_buffer(screen)),level_num+1,levels.length)
  end
end

mk_splash.splash
levels = load_levels
sleep(2)#sleep for a short time to allow the splash screen to be seen
Dispel::Screen.open(:colors => true) do |screen|
  main_loop(levels,screen)
end
mk_win_splash.splash
