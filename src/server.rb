require 'rcon'
require_relative 'constants'

class Server
  include Constants

  attr_reader :name, :ip, :port, :password, :rcon
  
  def initialize name, ip, port, password, rcon
    @name = name
    @ip = ip
    @port = port
    @password = password
    @rcon = rcon 

    @connected = false
  end
  
  #establish connection to server and auth
  def connect 
    @conn = RCon::Query::Source.new(ip, port)
    @connected = @conn.auth rcon
  end
  
  #execute any command passed
  def command cmd
    return unless connected? 
    @conn.command cmd
  end
  
  def cvar name
    return unless connected?
    @conn.cvar name
  end

  #change map
  def clvl map
    command "changelevel #{ map }"
  end
  
  def cpswd pswd
    command "password #{ pswd }"
  end
  
  def connected?
    @connected
  end
  
  def in_use?
    command("status") =~ /players : (\S+) /
    return $1.to_i > const["settings"]["used"]
  end
  
  def connect_info
    "connect #{ @ip }:#{ @port }; password #{ @password }"
  end
  
  def to_s
    @name
  end
end
