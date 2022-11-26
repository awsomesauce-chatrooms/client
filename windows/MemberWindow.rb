class MemberWindow < Window
  attr_accessor :members
  def first()
    @members = []
  end

  def add(string)
    @members.append(string)
    @members = @members.sort
  end

  def remove(string)
    @members.delete(string)
    @members = @members.sort
  end

  def render()
    for i in 1..@h-2
      @curses.setpos(i, 2)

      z = @members[i-1]
      if z != nil
        color = color_pair(0)

        if z.start_with?("@"); color = color_pair(2) end
        if z.start_with?(">"); color = color_pair(1) end

        @curses.attron(color) do
          x = @w-4
          y = z[0..15]
          @curses.addstr(y+(" "*(x-y.length)))
        end
      else
        @curses.addstr(" "*15)
      end
    end
  end
end
