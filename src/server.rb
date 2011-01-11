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
  end
  
  def connect
    @conn = RCon::Query::Source.new(ip, port)
    @conn.auth rcon
  end
  
  def disconnect
    @conn.disconnect if @conn
  end
  
  def command cmd
    @conn.command cmd
  end
  
  def cvar name
    @conn.cvar name
  end

  def clvl map
    command "changelevel #{ map }"
  end
  
  def cpswd pswd
    command "password #{ pswd }"
  end

  def players
    command("status") =~ /players : (\S+?) /
    return $1.to_i
  end
  
  def timeleft
    command("timeleft") =~ /map:  (\S+?),/
    return $1.to_s
  end
  
  def in_use?
    players > const["settings"]["used"]
  end
  
  def connect_info
    "connect #{ ip }:#{ port }; password #{ password }"
  end
  
  def to_s
    name
  end
end
