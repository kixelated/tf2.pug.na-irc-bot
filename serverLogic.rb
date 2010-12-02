require 'rcon'

module ServerLogic
  def start_server
		
	while current_server.inuse?
	  @state = Variables::State_serverinuse
	  message "Server  #{ current_server.ip } is in use. Waiting #{ Variables::Inuse_delay } seconds to try the next server."
      @servers.push @servers.shift
	  sleep Variables::Inuse_delay
    end
	
	current_server.cpswd current_server.pswd
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
