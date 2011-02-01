require 'steam-condenser'
require_relative 'constants'

class Server < SourceServer
  attr_reader :ip, :port, :name, :password, :rcon, :ftp
  
  def initialize details
    @name, @ip, @port, @password, @rcon, @ftp = *details
    super ip, port
    
    rcon_auth rcon
  end
  
  def timeleft
    rcon_exec("timeleft") =~ /map:  (\S+?),/
    return $1.to_s
  end
  
  def to_s
    "connect #{ ip }:#{ port }; password #{ password }"
  end
end
