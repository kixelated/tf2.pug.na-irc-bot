require 'net/ftp'
require 'fileutils'
require 'zip/zipfilesystem'

require_relative 'constants'

class Logs
  attr_accessor :ip, :user, :password, :dir

  def initialize details
    @ip, @user, @password, @dir = *details
  end

  def open_down
    @down = Net::FTP.open(ip, user, password).tap do |conn|
      conn.passive = true
      conn.chdir dir + "/logs" if dir + "/logs"
    end
  end
  
  def open_up
    @up = Net::FTP.open(Constants.const["logs"]["ftp"]["ip"], Constants.const["logs"]["ftp"]["user"], Constants.const["logs"]["ftp"]["password"]).tap do |conn|
      conn.passive = true
      conn.chdir Constants.const["logs"]["ftp"]["dir"] if Constants.const["logs"]["ftp"]["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def logs conn = @down
    conn.nlst.reject { |filename| !(filename =~ /.+\.log/) }
  end
  
  def update server
    logs.each do |filename|
      file = "#{ server }-#{ filename }"
      
      storage = "#{ Constants.const["logs"]["storage"] }-#{ server }"
      
      # TODO: Does storage exist?
      FileUtils.mkdir_p storage if storage and not Dir.exists? storage

      # Download file
      @down.gettextfile filename, storage + filename

      @up.puttextfile storage + filename, file
      
      # Delete local files
      FileUtils.rm storage + filename

      # Delete remote files
      @down.delete filename if Constants.const["logs"]["delete"]["remote"]
    end
  end
  
  def purge
    # TODO
  end
  
  def connect
    open_up
    open_down
  end
  
  def disconnect
    close @up
    close @down
  end
end
