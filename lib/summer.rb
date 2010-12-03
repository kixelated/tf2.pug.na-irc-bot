require 'socket'

Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |f| require f }

require File.dirname(__FILE__) + "/summer/handlers"

module Summer
  class Connection
    include Handlers
    attr_accessor :connection, :ready, :started, :config, :server, :port
    def initialize(server, port=6667, nick="TestBot", channel="#test.bot")
      @ready = false
      @started = false

      @server = server
      @port = port

      @config = {}
      @config[:channels] = []
      
      @config[:nick] = nick
      @config[:channel] = channel
    end
    
    def start
      connect!

      loop do
        startup! if @ready && !@started
        parse(@connection.gets)
        if @connection.eof?
          puts "Connection lost for message bot #{ @config[:nick] } Reconnecting in 60 seconds."
          sleep(60)
          puts "Attempting to reconnect message bot #{ @config[:nick] } Reconnecting in 60 seconds."
          @ready = false
          @started = false
          connect!
        end
      end

    end

    def msg(to, message)
      response("PRIVMSG #{to} :#{message}")
    end
    
    def notice(to, message)
      response("NOTICE #{to} :#{message}")
    end
    
    private
    def connect!
      @connection = TCPSocket.open(server, port)      
      response("USER #{config[:nick]} #{config[:nick]} #{config[:nick]} #{config[:nick]}")
      response("NICK #{config[:nick]}")
    end


    # Will join channels specified in configuration.
    def startup!
      nickserv_identify if @config[:nickserv_password]
      (@config[:channels] << @config[:channel]).compact.each do |channel|
        join(channel)
      end
      @started = true
      really_try(:did_start_up) if respond_to?(:did_start_up)
    end
    
    def nickserv_identify
      msg("nickserv", "register #{@config[:nickserv_password]} #{@config[:nickserv_email]}")
      msg("nickserv", "identify #{@config[:nickserv_password]}")
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
      # Privmsgs
      elsif raw == "PRIVMSG"
        message = words[3..-1].clean
        # Parse commands
        if /^!(\w+)\s*(.*)/.match(message) && respond_to?("#{$1}_command")
          really_try("#{$1}_command", parse_sender(sender), channel, $2)
        # Plain and boring message
        else
          sender = parse_sender(sender)
          method, channel = channel == me ? [:private_message, sender[:nick]]  : [:channel_message, channel]
          really_try(method, sender, channel, message)
        end
      # Joins
      elsif raw == "JOIN"
        really_try(:join, parse_sender(sender), channel)
      elsif raw == "PART"
        really_try(:part, parse_sender(sender), channel, words[3..-1].clean)
      elsif raw == "QUIT"
        really_try(:quit, parse_sender(sender), words[2..-1].clean)
      elsif raw == "KICK"
        really_try(:kick, parse_sender(sender), channel, words[3], words[4..-1].clean)
        join(channel) if words[3] == me && config[:auto_rejoin]
      elsif raw == "MODE"
        really_try(:mode, parse_sender(sender), channel, words[3], words[4..-1].clean)
      end

    end

    def parse_sender(sender)
      nick, hostname = sender.split("!")
      { :nick => nick.clean, :hostname => hostname }
    end

    # These are the raws we care about.
    def raws_to_handle
      ["422", "376"]
    end

    # Output something to the console and to the socket.
    def response(message)
      puts ">> #{message.strip}"
      @connection.puts(message)
    end

    def me
      config[:nick]
    end
    
    def log(message)
      File.open(config[:log_file]) { |file| file.write(message) } if config[:log_file]
    end

  end

end
