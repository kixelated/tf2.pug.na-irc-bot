require 'socket'

Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |f| require f }

require File.dirname(__FILE__) + "/messagebot/handlers"

class MessageBot
  include Handlers
  attr_accessor :connection, :ready, :started, :config, :server, :port, :nick, :channel
  
  def initialize(server, port, nick, channel, messagequeue)
    @ready = false
    @started = false
 
    @server = server
    @port = port
    @channel = channel
    @nick = nick
    
	connect!
    
    until @connection.eof? do
      startup! if @ready && !@started
	  parse(@connection.gets)
      if !messagequeue.empty? && @started
		message = messagequeue.pop 
		privmsg(message,@channel)
		sleep(1)
      end
	end
	  @ready = false
	  @started = false
  end
	
  def quit
    part(@channel)
    response("QUIT")
  end

    private

  def connect!
    @connection = TCPSocket.open(server, port)      
    response("USER #{@nick} #{@nick} #{@nick} #{@nick}")
    response("NICK #{@nick}")
  end

  # Will join channels specified in configuration.
  def startup!
    join(@channel)
    @started = true
  end
    
  # Go somewhere.
  def join(channel)
    response("JOIN #{channel}")
  end

  # Leave somewhere
  def part(channel)
    response("PART #{channel}")
  end

  # What did they say?
  def parse(message)
    puts "<< #{message.to_s.strip}"
    words = message.split(" ")
    sender = words[0]
    raw = words[1]
    channel = words[2]
    # Handling pings
    if /^PING (.*?)\s$/.match(message)
      response("PONG #{$1}")
    # Handling raws
    elsif /\d+/.match(raw)
      send("handle_#{raw}", message) if raws_to_handle.include?(raw)
    elsif raw == "KICK"
      join(channel) if words[3] == me
    end
  end

  # These are the raws we care about.
  def raws_to_handle
    ["422", "376"]
  end

  def privmsg(message, to)
    response("PRIVMSG #{to} :#{message}")
  end

  # Output something to the console and to the socket.
  def response(message)
    puts ">> #{message.strip}"
    @connection.puts(message)
  end

  def me
    @nick
  end
    
end