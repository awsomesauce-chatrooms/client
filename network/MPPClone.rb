require 'websocket-eventmachine-client'
require 'json'

class Network
  def initialize(app, ip, port)
    @app = app
    @ch = {}

    Thread.new do
      loop do
        sleep 10
        $ws.send JSON.dump([{"m" => "t", "e" => Time.now.to_i}])
      end
    end

    if File.exist?("config/MPPClone.txt")
      @token = File.read("config/MPPClone.txt")
    else
      puts "Create config/MPPClone.txt with your MPPClone config!"
      exit!
    end


    Thread.new do
      EM.run do
        $ws = WebSocket::EventMachine::Client.connect(:uri => 'wss://mppclone.com:8443')

        $ws.onopen do
          @app.chatwindow.add("connected")

          $ws.send JSON.dump([{"m" => "hi", "token" => @token}])
          $ws.send JSON.dump([{"m" => "ch", "_id" => "✧𝓓𝓔𝓥 𝓡𝓸𝓸𝓶✧"}])
        end

        $ws.onmessage do |msg, type|
          z = JSON.parse(msg)[0]

          if z["m"] == "a"
            @app.chatwindow.add("#{z["p"]["name"]} (#{z["p"]["id"].slice(0, 6)}): #{z["a"]}")
          end

          if z["m"] == "c"
            @app.chatwindow.text = []

            for y in z["c"]
              @app.chatwindow.add("#{y["p"]["name"]} (#{y["p"]["id"].slice(0, 6)}): #{y["a"]}")
            end

            @app.chatwindow.add("[CLIENT] Currently in: #{@ch["id"]}")

          end
          if z["m"] == "ch"
            @app.memberwindow.members = []
            for p in z["ppl"]
              @app.memberwindow.add("#{p["id"].slice(0, 2)} #{p["name"]}")
            end

            @ch = z["ch"]
          end

          if z["m"] == "p"
            for y in @app.memberwindow.members
              if z["_id"].slice(0, 2) == y.slice(0, 2)
                @app.memberwindow.remove(y)
              end
            end

            @app.memberwindow.add("#{z["id"].slice(0, 2)} #{z["name"]}")
          end

          if z["m"] == "bye"
            for y in @app.memberwindow.members
              if z["p"].slice(0, 2) == y.slice(0, 2)
                @app.memberwindow.remove(y)
              end
            end
          end
        end

        $ws.onclose do |code, reason|
          @app.chatwindow.add("[CLIENT] Disconnected with status code: #{code}")
        end
      end
    end
  end

  def sendChat(text)
    if text.start_with?("/ch ")
      ch = text.slice(4, text.length)

      if ch == ""
        $ws.send JSON.dump([{"m" => "ch", "_id" => "✧𝓓𝓔𝓥 𝓡𝓸𝓸𝓶✧"}])
      else
        $ws.send JSON.dump([{"m" => "ch", "_id" => ch}])
      end

      return
    end

    $ws.send JSON.dump([{"m" => "a", "message" => text}])

    if text.start_with?("> ")
      code = text.slice(2, text.length)

      begin
        result = eval(code)

        $ws.send JSON.dump([{"m" => "a", "message" => "@ Evaled: #{result}"}])
      rescue Exception => e
        lmfao = "#{e}"
        $ws.send JSON.dump([{"m" => "a", "message" => "@ Errored out: #{lmfao.slice(0, 64)}"}])
      end
    end
  end
end
