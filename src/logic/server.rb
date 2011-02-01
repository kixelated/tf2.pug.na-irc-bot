require 'chronic_duration'

require_relative '../server'
require_relative '../stv'

module ServerLogic
  def start_server
    @server.update_server_info
    
    while @server.server_info["number_of_players"] < const["settings"]["test"]
      message "Server #{ @server.name } is in use. Trying the next server in #{ const["delays"]["server"] } seconds."
      
      next_server
      sleep const["delays"]["server"]
    end
    
    @server.rcon_exec "changelevel #{ @map['file'] }"
  end
  
  def announce_server
    message "The pug will take place on #{ @server.name } with the map #{ @map["name"] }."
    advertisement
  end
  
  def change_map map, file
    @map = { "name" => map, "file" => file, "weight" => 0 }
  end
  
  def update_stv
    @updating = true
    
    @servers.each do |server|
      server.update_server_info
      unless server.server_info["number_of_players"] < const["settings"]["test"]
        message "#{ server } is in use, please wait until the pug has ended."
      else
        # TODO
        stv = STV.new server_d["ftp"]
        stv.connect
        
        count = stv.demos.size
        if count > 0
          message "Uploading #{ count } demos from #{ server }."
          stv.update server
        else
          message "No new demos on #{ server }."
        end
        
        stv.purge
        stv.disconnect
      end
    end
    
    @updating = false
  end
  
  def list_stv
    message "STV demos can be found here: #{ const["stv"]["url"] }"
  end
  
  def list_status
    @servers.each do |server|
      server.update_server_info
      info = server.server_info
      
      if server.server_info["number_of_players"] > 0
        message "#{ server.name }: #{ info['number_of_players'] } players on #{ info['map_name'] } with #{ server.timeleft } left"
      else 
        message "#{ server.name }: Empty"
      end
    end
  end

  def list_server
    message "#{ @server.to_s }"
    advertisement
  end  
  
  def list_map
    message "The current map is #{ @map["name"] }"
  end
  
  def list_mumble
    message "Mumble server info: #{ const["mumble"]["ip"] }:#{ const["mumble"]["port"] } #{ "password: #{ const["mumble"]["password"] }" if const["mumble"]["password"] } . Download Mumble here: http://mumble.sourceforge.net/"
    advertisement
  end
  
  def list_last
    message "The last match was started #{ ChronicDuration.output((Time.now - @last).to_i) } ago"
  end
  
  def list_rotation
    output = const["rotation"]["maps"].collect { |map| "#{ map["name"] }(#{ map["weight"] })" }
    message "Map(weight) rotation: #{ output * ", " }"
  end

  def next_server
    @server = @servers.push(@servers.shift).first
  end
  
  def next_map 
    @prev_maps << @map
    @prev_maps.shift if @prev_maps.size > const["rotation"]["exclude"]
  
    maps = const["rotation"]["maps"].reject { |map| @prev_maps.include? map }
    weight = maps.inject(0) { |sum, map| sum + map["weight"] } 
  
    num = rand weight
    maps.each do |map|
      num -= map["weight"]
      return (@map = map) if num <= 0
    end
  end
  
  def advertisement
    message "Servers are provided by #{ colourize "End", const["colours"]["orange"] } of #{ colourize "Reality", const["colours"]["orange"] }: #{ colourize "http://eoreality.net", const["colours"]["orange"] } #eoreality"
  end
end
