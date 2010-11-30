require 'rcon'

module ServerLogic
  def start_server
    current_server.clvl current_map

    @servers.push @servers.shift
    @maps.push @maps.shift
  end

  def list_server
    message current_server.to_s
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
