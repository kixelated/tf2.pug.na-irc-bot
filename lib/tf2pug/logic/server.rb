require 'chronic_duration'
require 'fileutils'
require 'net/ftp'

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
    FileUtils.mkdir Constants.stv['storage'] if not Dir.exists?(Constants.stv['storage'])
  
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
    up = Net::FTP.open(Constants.stv['ftp']['ip'], Constants.stv['ftp']['user'], Constants.stv['ftp']['password'])
    up.chdir Constants.stv['ftp']['dir'] if Constants.stv['ftp']['dir']
    up.passive = true
    
    files = Dir[Constants.stv['storage'] + "*.zip"]
    files.each do |file|
      filename = File.basename(file)
      
      up.putbinaryfile fiFileUtils.mkdir storage if not Dir.exists?(storage)le, File.basename(filename + ".tmp")
      up.rename filename + ".tmp", filename
      
      FileUtils.rm file
    end
    
    FileUtils.rm_dir Constants.stv['storage']
    
    result = files.size
    message "#{ result } demos uploaded." if result > 0
  end
  
  def self.purge_demos
    up = Net::FTP.open(Constants.stv['ftp']['ip'], Constants.stv['ftp']['user'], Constants.stv['ftp']['password']) # TODO: Clean up constants
    up.chdir Constants.stv['ftp']['dir'] if Constants.stv['ftp']['dir']
  
    up.nlst.each do |filename|
      if filename =~ /(.+?)-(.{4})(.{2})(.{2})-(.{2})(.{2})-(.+)\.dem/
        server, year, month, day, hour, min, map = $1, $2, $3, $4, $5, $6, $7
        up.delete filename if Time.mktime(year, month, day, hour, min) + Constants.stv['purge'] < Time.now
      end
    end
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
  
  def self.list_map map
    message "The current map is #{ map.name }"
  end
  
  def self.list_mumble
    message "Mumble server info: #{ Constants.mumble['ip'] }:#{ Constants.mumble['port'] } password: #{ Constants.mumble['password'] } . Download Mumble here: http://mumble.sourceforge.net/"
    advertisement
  end
  
  def self.list_last
    message "The last match was started #{ ChronicDuration.output(Time.now - Server.max(:played_at)) } ago"
  end
  
  def self.list_rotation
    output = Map.all.collect { |map| "#{ map.name }(#{ map.weight })" }
    message "Map(weight) rotation: #{ output * ", " }"
  end
  
  def self.advertisement
    message "Servers are provided by #{ colourize "End", :orange } of #{ colourize "Reality", :orange }: #{ colourize "http://eoreality.net", :orange } #eoreality"
  end
end
