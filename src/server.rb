require 'steam-condenser'
require_relative 'constants'

class Server < SourceServer
  attr_accessor :details, :stv

  def timeleft
    rcon_exec("timeleft") =~ /map:  (\S+?),/
    return $1.to_s
  end
  
  def name; details['name']; end
  def password; details['password']; end
  def rcon; details['rcon']; end

  def to_s
    name
  end
  
  def connect_info
    "connect #{ host }:#{ port }; password #{ password }"
  end
end
