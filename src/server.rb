require 'rcon'
require_relative 'constants'

class Server
  include Constants

  attr_reader :ip, :port, :name, :password, :rcon
  
  def initialize details
    @name = details["name"]
    @ip = details["ip"]
    @port = details["port"]
    @password = details["password"]
    @rcon = details["rcon"] 

    @connected = false
  end
  
  def connect
    @conn = RCon::Query::Source.new(ip, port)
    @connected = @conn.auth rcon
  end
  
  def close
    @conn.disconnect if @conn
    @connected = false
  end
  
  def command cmd
    connect unless connected? 
    @conn.command cmd
  end
  
  def cvar name
    connect unless connected?
    @conn.cvar name
  end

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
    "connect #{ ip }:#{ port }; password #{ password }"
  end
  
  def to_s
    name
  end
end
