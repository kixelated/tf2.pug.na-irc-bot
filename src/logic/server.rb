require 'chronic_duration'

require_relative '../server'
require_relative '../stv'

module ServerLogic
  def start_server
    started = false
    
    while not started
      begin
        @server.update_server_info
        
        while @server.server_info["number_of_players"] >= const["settings"]["used"]
          message "#{ @server.name } is in use. Trying the next server in #{ const["delays"]["server"] } seconds."
          
          next_server
          sleep const["delays"]["server"]
          
          @server.update_server_info
        end
        
        @server.authorize
        @server.rcon_exec "changelevel #{ @map['file'] }"
        
        started = true
      rescue
        message "Error connecting to #{ @server.name }. Trying the next server in #{ const["delays"]["server"] } seconds."
          
        next_server
        sleep const["delays"]["server"]
      end
    end
  end
  
  def announce_server
    message "The pug will take place on #{ @server.name } with the map #{ @map['name'] }."
    advertisement
  end
  
  def change_map map, file
    @map = { 'name' => map, 'file' => file, 'weight' => 0 }
  end
  
  def update_stv
    @updating = true
    
    thread_servers do |server|
      server.update_server_info
      
      if server.server_info["number_of_players"] >= const["settings"]["used"]
        message "#{ server } is in use, please wait until the pug has ended."
      else
        server.stv.connect
        count = server.stv.demos.size
        
        if count > 0
          message "Uploading #{ count } demos from #{ server.name }."
          server.stv.update server.name
        else
          message "No new demos on #{ server.name }."
        end
        
        server.stv.purge
        server.stv.disconnect
      end
    end
    
    @updating = false
  end
  
  def list_stv
    message "STV demos can be found here: #{ const["stv"]["url"] }"
  end
  
  def list_status
    thread_servers do |server|
      server.update_server_info
      info = server.server_info
      
      if server.server_info["number_of_players"] >= const["settings"]["used"]
        server.authorize
        message "#{ server.name }: #{ info['number_of_players'] } players on #{ info['map_name'] } with #{ server.timeleft } left"
      else
        message "#{ server.name }: empty"
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
  
  def thread_servers
    threads = []
    @servers.each do |server|
      threads << Thread.new(server) do |server|
        yield server
      end
    end
    threads.each { |thread| thread.join }
  end
  
  def advertisement
    message "Servers are provided by #{ colourize "End", const["colours"]["orange"] } of #{ colourize "Reality", const["colours"]["orange"] }: #{ colourize "http://eoreality.net", const["colours"]["orange"] } #eoreality"
  end
end
