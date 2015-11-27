require_relative 'moving'
class Player < Moving
  def move(delta)
    new_pos = [y+delta[0],x+delta[1]]
    if not @level.moving_at?(new_pos)
      super delta
    else
      if @level.moving_at(new_pos).move(delta)
        super delta
      end
    end
  end
end