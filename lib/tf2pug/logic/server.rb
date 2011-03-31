require 'chronic_duration'

require 'tf2pug/model/map'
require 'tf2pug/model/server'

module ServerLogic
  def self.start_server server, map
    Server.all(:order => :played_at.asc).cycle(2) do |server|
      begin
        return server if server.start(map)
      rescue Exception => e
        message "Error starting #{ server.name }: #{ e.message }."
      end
    end
  end
  
  def self.announce_server server, map
    message "The pug will take place on #{ server.name } with the map #{ map.name }."
    advertisement
  end
  
  def self.download_demos
    Server.all.each do |server|
      begin
        result = server.download_demos
        message "#{ result } demos downloaded from #{ server.name }." if result > 0
      rescue Exception => e
        message "Error downloading from #{ server.name }: #{ e.message }."
      end
    end
  end
  
  def self.upload_demos
    # TODO: Get FTP object somehow
  end
  
  def self.purge_demos
    # TODO: Get FTP object somehow
  end
  
  def self.list_stv
    message "STV demos can be found here: #{ Constants.stv['url'] }"
  end
  
  def self.list_status
    Server.all.each do |server|
      message "#{ server.name }: #{ server.status }"
    end
  end

  def self.list_server server
    message "#{ server.name }: #{ server.connect_info }"
    advertisement
  end
  
  def self.list_mumble
    message "Mumble server info: #{ Constants.mumble['ip'] }:#{ Constants.mumble['port'] } password: #{ Constants.mumble['password'] } . Download Mumble here: http://mumble.sourceforge.net/"
    advertisement
  end
  
  def self.list_last
    message "The last match was started #{ ChronicDuration.output(Time.now - Server.max(:played_at)) } ago"
  end
  
  def self.advertisement
    message "Servers are provided by #{ colourize "End", :orange } of #{ colourize "Reality", :orange }: #{ colourize "http://eoreality.net", :orange } #eoreality"
  end
end
