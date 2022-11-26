require 'socket'
require "./libs/Packets.rb"

$dataLengths = {0 => 128, 1 => 128, 2 => 128, 3 => 128, 4 => 256}

class Network
  def initialize(app, ip, port)
    @app = app

    unless Dir.exist?("config")
      Dir.mkdir("config")
    end

    if File.exist?("config/#{ip}#{port}token.txt")
      @token = File.read("config/#{ip}#{port}token.txt")
    else
      @token = " "
    end

    @socket = TCPSocket.new ip, port

    @socket.send((PacketWrite.new).writeByte(0x00).writeString(@token).extract(), 0)

    Thread.new do
      loop do
        begin
          readID = @socket.recv(1)
        rescue
          puts "connection broke while recv"
          break
        end

        if !readID.empty?
          packetID = readID.ord;

          length = $dataLengths[packetID]

          unless length
              puts "#{packetID} unknown"
              break
          end

          packet = ""

          packet = @socket.recv(length)

          unless packet
              puts "packet read attempt failed"
              break
          end

          parser = PacketParser.new(packet)

          if packetID == 0
            token = parser.readString()
            File.write("config/#{ip}#{port}token.txt", token)

            @app.chatwindow.add("[Client] Network authenicated.")
            @app.chatwindow.add("[Client] Token authenicated #{token}")
          end

          if packetID == 1
            message = parser.readString()
            @app.chatwindow.add(message)
          end

          if packetID == 2
            username = parser.readString()
            @app.chatwindow.add("[Client] #{username} joined")

            @app.memberwindow.add(username)
          end

          if packetID == 3
            username = parser.readString()

            @app.chatwindow.add("[Client] #{username} left")
            @app.memberwindow.remove(username)
          end

          if packetID == 4
            from = parser.readString()
            to = parser.readString()
            @app.chatwindow.add("[Client] #{from} changed their name to #{to}")

            @app.memberwindow.remove(from)
            @app.memberwindow.add(to)
          end
        end
      end

      @socket.close
    end
  end

  def sendChat(text)
    if @socket
      @socket.send((PacketWrite.new).writeByte(0x01).writeString(text).extract(), 0)
    end
  end
end
