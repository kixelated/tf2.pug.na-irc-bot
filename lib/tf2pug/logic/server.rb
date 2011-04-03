require 'chronic_duration'

require 'tf2pug/bot/irc'
require 'tf2pug/model/map'
require 'tf2pug/model/server'

module ServerLogic
  def self.start_server(server, map)
    Server.all(:order => :played_at.asc).cycle(2) do |server|
      begin
        return server if server.start(map)
      rescue Exception => e
        Irc.message "Error starting #{ server.name }: #{ e.message }"
      end
    end
  end
  
  def self.announce_server(server, map)
    Irc.message "The pug will take place on #{ server.name } with the map #{ map.name }."
    advertisement
  end
  
  def self.download_demos
    Server.all.each do |server|
      begin
        result = server.download_demos
        Irc.message "#{ result } demos downloaded from #{ server.name }." if result > 0
      rescue Exception => e
        Irc.message "Error downloading from #{ server.name }: #{ e.message }"
      end
    end
  end
  
  def self.upload_demos
    result = nil
  
    Ftp.all(:web => true).each do |ftp|
      begin
        result = ftp.upload_demos
      rescue Exception => e
        Irc.message "Error uploading demos to #{ ftp.host }: #{ e.message }"
      end
    end
    
    if result    
      Irc.message "#{ result } demos uploaded."
      Ftp.delete_demos
    end
  end
  
  def self.purge_demos
    Ftp.all(:web => true).each do |ftp|
      ftp.purge_demos
    end
  end
  
  def self.list_stv
    Irc.message "STV demos can be found here: #{ Constants.stv['url'] }"
  end
  
  def self.list_status
    Server.all.each do |server|
      Irc.message "#{ server.name }: #{ server.status }"
    end
  end

  def self.list_server(server)
    Irc.message "#{ server.name }: #{ server.connect_info }"
    advertisement
  end
  
  def self.list_mumble
    Irc.message "Mumble server info: #{ Constants.mumble['ip'] }:#{ Constants.mumble['port'] } password: #{ Constants.mumble['password'] } . Download Mumble here: http://mumble.sourceforge.net/"
    advertisement
  end
  
  def self.list_last
    Irc.message "The last match was started #{ ChronicDuration.output(Time.now - Server.max(:played_at)) } ago"
  end
  
  def self.advertisement
    Irc.message "Servers are provided by #{ colourize "End", :orange } of #{ colourize "Reality", :orange }: #{ colourize "http://eoreality.net", :orange } #eoreality"
  end
end
