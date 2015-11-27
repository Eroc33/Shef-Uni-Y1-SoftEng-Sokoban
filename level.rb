require 'dispel'
require_relative  'box'
require_relative  'player'

class Level

  attr_reader :static, :moving, :player, :width, :height

  def initialize(level_arr)
    (@static,@moving,start_pos) = parse_level(level_arr)
    @player = Player.new(self,start_pos)
    (@width,@height) = size
  end

  def make_view
    buff = Array.new(@height) { Array.new(@width) }
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
      buff[box.y][box.x] = '$'
    end

    map.add(:reverse, @player.y, @player.x..@player.x)

    [(buff.map do |buff_line|
      buff_line.join('')
    end).join("\n"),map]
  end

  def moving_at?(pos)
    @moving.each do |moving|
      if moving.pos == pos
        return true
      end
    end
    false
  end

  def moving_at(pos)
    @moving.each do |moving|
      if moving.pos == pos
        return moving
      end
    end
    nil
  end

  def static_at(pos)
    @static[pos[0]][pos[1]]
  end

  def set_filled(pos)
    @static[pos[0]][pos[1]] = :filled
  end

  def complete?
    not @static.any? do |row|
      row.any? do |tile|
        tile == :storage
      end
    end
  end

  def remove_moving(moving)
    @moving.delete(moving)
  end

  def in_wall?(pos)
    @static[pos[0]][pos[1]] == :wall
  end

  protected

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