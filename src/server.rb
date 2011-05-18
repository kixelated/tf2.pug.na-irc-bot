require 'steam-condenser'
require_relative 'constants'

class Server < SourceServer
  attr_accessor :details, :stv, :logs

  def tournament_info connect = true
    rcon_connect rcon if connect
    temp = rcon_exec("tournament_info").scan(/(\w+): "([^"]*)"/)
    rcon_disconnect if connect
    
    Hash[temp]
  end
  
  def name; details['name']; end
  def password; details['password']; end
  def rcon; details['rcon']; end
  def beta; details['beta']; end

  def to_s
    name
  end
  
  def connect_info
    "connect #{ host }:#{ port }; password #{ password }"
  end
end
