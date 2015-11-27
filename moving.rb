class Moving
  attr_reader :pos
  def initialize(level,pos)
    @pos = pos
    @level = level
  end

  def move(delta)
    new_pos = [@pos[0]+delta[0],@pos[1]+delta[1]]
    if @level.in_wall?(new_pos) || @level.moving_at?(new_pos)
      false
    else
      @pos = new_pos
      true
    end
  end

  def y
    @pos[0]
  end

  def x
    @pos[1]
  end

  protected

  def y=(new_y)
    @pos[0] = new_y
  end

  def x=(new_x)
    @pos[1] = new_x
  end

  def clamp_pos
    self.y = clamp(0,@level.width,self.y)
    self.x = clamp(0,@level.height,self.x)
  end

  def clamp(min,max,val)
    [[val,max].min,min].max
  end
end