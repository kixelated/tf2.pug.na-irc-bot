require 'steam-condenser'
require_relative 'constants'

class Server < SourceServer
  attr_reader :name, :password, :rcon_pass, :stv
  
  def initialize(details)
    @name, ip, port, @password, @rcon_pass, stv = *details.values
    @stv = STV.new(stv.values)
    
    super ip, port
  end
  
  def timeleft
    rcon_exec("timeleft") =~ /map:  (\S+?),/
    return $1.to_s
  end
  
  def to_s
    name
  end
  
  def connect_info
    "connect #{ ip }:#{ port }; password #{ password }"
  end
end
