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

def append_status_line(view,level_num,total_levels)
  (buff,map) = view
  buff[-1] = "level_num #{level_num}/#{total_levels}"
  map.add(:reverse, -1, 0..(buff[-1].length))
  [buff.join("\n"),map]
end

def main_loop(start_level,levels,screen)
  #initial level
  level_num = start_level
  level = Level.new(levels[level_num])
  #initial screen
  screen.draw *append_status_line(level.make_view(screen.lines,screen.columns),level_num+1,levels.length)
  Dispel::Keyboard.output do |key|
    #input
    case key
      when 'q'
        break
      when :down
        level.player.move([1,0])
      when :up
        level.player.move([-1,0])
      when :right
        level.player.move([0,1])
      when :left
        level.player.move([0,-1])
      when 'r'
        level = Level.new(levels[level_num])
    end
    #advance level if complete
    if level.complete?
      level_num += 1
      if level_num >= levels.length
        break
      end
      level = Level.new(levels[level_num])
    end
    #update screwen
    screen.draw *append_status_line(level.make_view(screen.lines,screen.columns),level_num+1,levels.length)
  end
end

def mk_box(width,height)
  inner_width = width - 2
  inner_height = height - 2
  top_and_bottom = ['-'*width]
  buff =  top_and_bottom + ['|'+' '*inner_width+'|']*inner_height + top_and_bottom
end

def offset_buff(buff,x,y)
  x_padding = ' '*x
  y_padding = ['']*y
  y_padding + buff.map do |line|
    x_padding + line
  end
end

def mk_menu(screen)
  buff = mk_box(11,11)
  buff[1] = '| sokoban |'
  buff[2] = '-----------'
  buff[3] = '| [s]tart |'
  buff[5] = '| [l]evel |'
  buff[6] = '|  select |'
  buff[7] = '| ([q]uit)|'
  offset_buff(buff,screen.columns/2-11,screen.lines/2-11).join("\n")
end

def mk_select(screen,max_level,selected)
  displayed = (selected == ''? 0 : selected).to_s
  buff = mk_box(11,11)
  buff[1] = '| level   |'
  buff[2] = '| select  |'
  buff[3] = '|---------|'
  buff[4] = "|#{displayed.rjust(9,' ')}|"
  buff[5] = '|---------|'
  buff[6] = "| (1-#{max_level.to_s.rjust(3,' ')}) |"
  buff[9] = '| ([q]uit)|'
  offset_buff(buff,screen.columns/2-11,screen.lines/2-11).join("\n")
end

def is_numeric?(key)
  key == key.to_i.to_s
end

def menu(screen,max_level)
  screen.draw mk_menu(screen)
  selecting = false
  selected = ''
  Dispel::Keyboard.output do |key|
    if selecting
      case key
        when :enter
          #user selection is 1..90 we want 0..89
          return (selected.to_i - 1)
        when :backspace
          selected = selected[0..-2]
        when 'q'
          selecting = false
          selected = ''
      end
      if !key.is_a?(Symbol) && is_numeric?(key)
        new = selected + key.to_i.to_s
        #simplest way to prevent user choosing a bad level number, just don't let them enter it
        if (new.to_i-1) < max_level
          selected += key.to_i.to_s
        end
      end
    else
      case key
        when 's'
          return 0
        when 'l'
          selecting = true
        when 'q'
          exit 0
      end
    end
    #draw in case we switched submenus while evaluating input
    if selecting
      screen.draw mk_select(screen,max_level,selected)
    else
      screen.draw mk_menu(screen)
    end
  end
end

mk_splash.splash
levels = load_levels
sleep(2)#sleep for a short time to allow the splash screen to be seen
Dispel::Screen.open(:colors => true) do |screen|
  start_level = menu(screen,levels.length)
  main_loop(start_level,levels,screen)
end
mk_win_splash.splash
