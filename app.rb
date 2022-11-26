#!/usr/bin/env ruby

require "curses"
require "./windows/Window.rb"
require "./windows/MemberWindow.rb"
require "./windows/InputWindow.rb"
require "./windows/ChatWindow.rb"
require "./network/Network.rb"

include Curses

class App
  attr_accessor :net, :inputwindow, :memberwindow, :chatwindow

  def initialize(ip, port)
    @windows = []

    @thisIsJustToPrematurelyTripTheWarning = IO::Buffer.new

    initCurses()
    initializeWindows()

    @net = Network.new(self, ip, port)

    start()
  end

  def initCurses()
    Curses.init_screen
    Curses.nl
    Curses.noecho
    Curses.curs_set 0
    Curses.crmode
    Curses.start_color

    Curses.init_pair(1, 105, COLOR_BLACK)
    Curses.init_pair(2, 141, COLOR_BLACK)
  end

  def initializeWindows() # TODO: this function is kind of disgusting, figure out a way to compress offsets
    # calculate offsets
    hratio = 3
    wratio = 20

    input = [hratio, Curses.cols, Curses.lines-hratio, 0]
    member = [Curses.lines-hratio, wratio, 0, Curses.cols-wratio]
    chat = [Curses.lines-hratio, Curses.cols-wratio, 0, 0]

    if @windows.length == 0
      @inputwindow = InputWindow.new(input[0], input[1], input[2], input[3], self)
      @memberwindow = MemberWindow.new(member[0], member[1], member[2], member[3], self)
      @chatwindow = ChatWindow.new(chat[0], chat[1], chat[2], chat[3], self)

      @windows = [
        @inputwindow,
        @memberwindow,
        @chatwindow
      ]
    else
      # let's resize them if they're already made
      @memberwindow.resize(member[0], member[1], member[2], member[3])
      @inputwindow.resize(input[0], input[1], input[2], input[3])
      @chatwindow.resize(chat[0], chat[1], chat[2], chat[3])
    end
  end

  def start()
    Thread.new do
      loop do
        for w in @windows
          if w.respond_to?(:rawRender)
            sleep 0.1
            # we can go this high because everything else that needs to be updated
            # real time can update themselves and it's not that big of a issue

            w.rawRender
          end
        end
      end
    end

    loop do
      sleep 0

      begin
        d = Curses.getch
      rescue
        return
      end

      unless d.nil?
        if d == "q"
          break
        end

        if d == Curses::KEY_RESIZE
          Curses.clear

          initializeWindows
          next
        end

        for w in @windows
          if w.respond_to?(:handle)
            w.handle(d)
          end
        end
      else
        sleep 1
      end
    end

    Curses.close_screen

  end
end
