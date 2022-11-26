class Logging
  def initialize(domain)
    @time = Time.now
    @domain = domain

    unless Dir.exist?("logs")
      Dir.mkdir("logs")
    end

    unless Dir.exist?("logs/#{@domain}")
      Dir.mkdir("logs/#{@domain}")
    end
  end

  def log(string)
    File.write("logs/#{@domain}/#{@time}.log", string+"\n", mode: 'a+')
  end
end
