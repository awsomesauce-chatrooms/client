require "./libs/Logging.rb"

class ChatWindow < Window
  attr_accessor :text
  def first()
    @text = []
    @logging = Logging.new "chat"
  end

  def add(string)
    @logging.log(string)

    @text.append(string)
    @text = @text.last(@h-3)
  end

  def remove(string)
    @text.delete(string)
    @text = @text.last(@h-3)
  end

  def render()
    @text.each_with_index do |val, index|
      @curses.setpos(index+1, 2)
      z = @w-4
      y = val[0..z-1]

      size = (z-y.length)
      if size < 0; size = 0 end;

      @curses.addstr(y+(" "*size))
    end

    @curses.setpos(@text.length+1, 2)
    @curses.addstr(" "*(@w-4))
  end
end
