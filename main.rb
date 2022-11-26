require "./app.rb"
require 'optparse'

@ip = ""
@port = -1

OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-l", "--help", "Prints this help") do
    puts opts
    exit
  end

  opts.on("-h", "--host HOST", "Set a HOST for the network") do |v|
    @ip = v
  end

  opts.on("-p", "--port PORT", "Set a PORT for the network") do |v|
    @port = v
  end
end.parse!

if @ip == "" or @port == -1
  puts "IP and Port are both required! Example: ruby main.rb -p 8080 -h localhost"
  return
end

App.new(@ip, @port)
