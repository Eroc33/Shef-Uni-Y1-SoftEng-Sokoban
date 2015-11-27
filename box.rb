require_relative 'moving'
class Box < Moving
  def move(delta)
    new_pos = [y+delta[0],x+delta[1]]
    if @level.static_at(new_pos) == :storage
      @level.set_filled(new_pos)
      @level.remove_moving(self)
    else
      super(delta)
    end
  end
end