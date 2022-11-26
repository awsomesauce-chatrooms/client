class Window
  attr_accessor :curses, :extra
  def initialize(h, w, t, l, app, extra = {})
    @curses = Curses::Window.new(h, w, t, l)
    @app = app

    resize(h, w, t, l)

    first()
  end

  def resize(h, w, t, l)
    @h = h
    @w = w
    @t = t
    @l = l

    @curses.resize(h, w)
    @curses.move(t, l)
    @curses.clear

    @curses.attron(color_pair(1)) do
      @curses.attron(Curses::A_ALTCHARSET) do
        @curses.box(120, 113)
      end
    end
  end

  def rawRender()
    @curses.refresh
    render()
  end
end
