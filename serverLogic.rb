require 'rcon'

module ServerLogic
  def start_server
    @state = Variables::State_server

    while current_server.in_use?
      message "Server #{ current_server.to_s } is in use. Trying the next server in #{ Variables::Server_delay } seconds."
      
      @servers.push @servers.shift
      sleep Variables::Server_delay
    end

    current_server.cpswd current_server.pswd
    current_server.clvl current_map
    
    message "The pug will take place on #{ current_server.to_s } with the map #{ current_map }"
  end
  
  def change_map user, map
    return notice user, "That map is not in the rotation. Valid maps are: #{ @maps.join(", ") }" unless @maps.include? map
    
    @maps.unshift @maps.delete(map)
  end

  def list_server
    message "#{ current_server.connect_info }"
    message "Servers are provided by Apoplexy Industries: http://aigaming.com"
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
