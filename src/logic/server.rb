require 'chronic_duration'

require_relative '../server'
require_relative '../stv'

module ServerLogic
  def find_server
    first = true
  
    begin
      started = start_server
    rescue Exception => e
      if first
        message "#{ e.message }. Trying server again in #{ const["delays"]["server"] } seconds."
        first = false
      else
        message "#{ e.message }. Trying the next server in #{ const["delays"]["server"] } seconds."
        next_server
      end
      
      sleep const["delays"]["server"]
    end while not started
  end
  
  def start_server
    info = @server.update_server_info
    
    raise Exception.new("Could not connect to #{ @server }") unless info
    raise Exception.new("#{ @server } in use") unless info["number_of_players"] < const["settings"]["used"]
    
    @server.rcon_connect @server.rcon
    @server.rcon_exec "changelevel #{ @map['file'] }"
    @server.rcon_disconnect
    
    return true
  end
  
  def announce_server
    message "The pug will take place on #{ @server } with the map #{ @map['name'] }."
    advertisement
  end
  
  def change_map map, file
    @map = { 'name' => map, 'file' => file, 'weight' => 0 }
  end
  
  def update_stv
    begin
      @updating = true
    
      thread_servers do |server|
        info = server.update_server_info
        
        if info["number_of_players"] >= const["settings"]["used"]
          message "#{ server } is in use, please wait until the pug has ended."
        else
          server.stv.connect
          count = server.stv.demos.size
          
          if count > 0
            message "Uploading #{ count } demos from #{ server }."
            server.stv.update server
          else
            message "No new demos on #{ server.name }."
          end
          
          server.stv.purge
          server.stv.disconnect
        end
      end
    
      message "Finished uploading demos."
    ensure
      @updating = false
    end
  end
  
  def list_stv
    message "STV demos can be found here: #{ const["stv"]["url"] }"
  end
  
  def list_status
    thread_servers do |server|
      server.update_server_info
      info = server.server_info
      
      if info and info["number_of_players"] >= const["settings"]["used"]
        tinfo = server.tournament_info
        if tinfo
          score = tinfo['Score'].split(':').collect.with_index { |x, i| colourize x, const['teams']['details'][i]['colour'] }
          message "#{ server }: #{ score } on #{ info['map_name'] } with #{ tinfo['Timeleft'] } remaining."
        else
          message "#{ server }: Warmup on #{ info['map_name'] } with #{ info['number_of_players'] } connected."
        end
      else
        message "#{ server }: Empty."
      end
    end
  end

  def list_server
    message "#{ @server }: #{ @server.connect_info }"
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
