require 'rcon'

module ServerLogic
  def start_server
    @state = Variables::State_server
    @servers.push @servers.shift

    while current_server.used?
      message "Server #{ current_server.ip } is in use. Trying the next server in #{ Variables::Server_delay } seconds."
      
      @servers.push @servers.shift
      sleep Variables::Server_delay
    end 

    current_server.cpswd current_server.pswd
    current_server.clvl current_map
    
    @maps.push @maps.shift
  end
  
  def change_map user, map
    return notice user, "That map is not in the rotation. Valid maps are: #{ @maps.join(", ") }" unless @maps.include? map
    
    @maps.unshift @maps.delete(map)
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
