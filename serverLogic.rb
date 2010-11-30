require 'rcon'

module ServerLogic
  def start_server
    current_server.connect
    current_server.clvl

    @servers.push @servers.shift
    @maps.push @maps.shift
  end
  
  def connect_info
    "connect #{ current_server.ip }:#{ current_server.port }; password #{ current_server.pswd }"
  end
  
  def list_server
    message connect_info
  end  
  
  def list_map
    message "The current map is #{ current_map }"
  end

  def current_server
    @servers.first
  end
  
  def current_map
    @maps.first
  end
end
