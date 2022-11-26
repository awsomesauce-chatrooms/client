class InputWindow < Window
  def first()
    @placeholder = "[ message ]"
    @text = ""
  end

  def render()
    if @text == ""
      @text = @placeholder
    end

    @curses.setpos(1, 2)
    size = (@w - @text.length-3)

    if size < 0; size = 0 end;

    @curses.addstr(@text + (" " * size))
  end

  def handle(c)
    if @text == @placeholder
      @text = ""
    end

    if c == 127 or c == 8
      @text = @text.chop
      return
    end

    if c == 10
      if @text == ""; return end
      @app.net.sendChat(@text)

      @text = ""
      return
    end

    if @text.length > @w-5; return; end
    if
      @text += "#{c}"
    end
    rawRender
  end
end
