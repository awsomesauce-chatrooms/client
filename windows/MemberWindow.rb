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
          y = z[0..@w-3]

          size = (x-y.length)
          if size < 0; size = 0 end;

          @curses.addstr(y+(" "*size))
        end
      else
        @curses.addstr(" "*(@w-4))
      end
    end
  end
end
