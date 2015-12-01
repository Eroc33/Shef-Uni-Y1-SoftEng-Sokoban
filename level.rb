require 'dispel'
require_relative  'box'
require_relative  'player'

def error(str)
  puts str
  exit 1
end

class Level

  attr_reader :static, :moving, :player, :width, :height

  def initialize(level_file_lines)
    (@static,@moving,start_pos) = parse_level(level_file_lines)
    @player = Player.new(self,start_pos)
    (@width,@height) = size
  end

  #create a string to draw to the console
  def make_view(lines,columns)
    buff = Array.new(lines) { Array.new(columns) }
    map = Dispel::StyleMap.new(buff.length)
    @static.each_with_index  do |line,y|
      buff[y] = []
      line.each_with_index  do |val,x|
        buff[y][x] =
        case val
          when :wall
            '#'
          when :storage
            map.add(['#aa0000','#000000'], y, x..x)
            '.'
          when :filled
            map.add(['#654321','#000000'], y, x..x)
            '*'
          else ' '
        end
      end
    end
    buff[@player.y][@player.x] = '@'

    @moving.each do |box|
      map.add(['#654321','#000000'], box.y, box.x..box.x)
      if static_at([box.y,box.x]) == :storage
        buff[box.y][box.x] = '*'
      else
        buff[box.y][box.x] = '$'
      end
    end

    map.add(:reverse, @player.y, @player.x..@player.x)

    [(buff.map do |buff_line|
      buff_line.join('')
    end),map]
  end

  #returns true if there is a ''moving object'' at pos
  def moving_at?(pos)
    @moving.each do |moving|
      if moving.pos == pos
        return true
      end
    end
    false
  end

  #return the ''moving object'' at pos
  def moving_at(pos)
    @moving.each do |moving|
      if moving.pos == pos
        return moving
      end
    end
    nil
  end

  #return a symbol for the type of static object at pos
  def static_at(pos)
    @static[pos[0]][pos[1]]
  end

  #have we completed the level
  def complete?
    @moving.all? do |box|
      static_at([box.y,box.x]) == :storage
    end
  end

  #is pos a wall
  def in_wall?(pos)
    static_at(pos) == :wall
  end

  protected

  #load a level array
  def parse_level(level_arr)
    start_pos = [0,0]
    static = []
    moving = []
    level_arr.each_with_index  do |line,y|
      static[y] = []
      static[y][0..line.length] = :none
      line.each_with_index  do |char,x|
        case char
          when '@'
            start_pos = [y,x]
          when '$'
            moving << Box.new(self,[y,x])
          when '#'
            static[y][x] = :wall
          when '.'
            static[y][x] = :storage
          when ' '
            static[y][x] = :none
          when '*'
            moving << Box.new(self,[y,x])
            static[y][x] = :storage
          else
            error('Unknown symbol in level file!')
        end
      end
    end
    [static,moving,start_pos]
  end

  def size
    height = @static.length
    width = 0
    @static.each  do |line|
      width = [width,line.length].max
    end
    [width,height]
  end

end