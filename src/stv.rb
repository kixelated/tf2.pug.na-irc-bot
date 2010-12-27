require 'net/ftp'
require 'fileutils'

require_relative 'constants'

class STV
  include Constants

  def initialize server
    @server = server
  end

  def demos
    @down = open @server
    @down.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
  end
  
  def open ftp
    Net::FTP.new(ftp["ip"]).tap do |conn|
      conn.login ftp["user"], ftp["password"]
      conn.chdir ftp["dir"] if ftp["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def update
    stv = const["stv"] # saves some typing
    filepath = stv["path"]
    
    @@up = open stv["ftp"] # class variable so the connection can be shared
    @down = open @server

    demos.each do |filename|
      file = filepath + filename
    
      @down.getbinaryfile filename, file
      @down.delete filename if stv["delete"]["remote"]
      @@up.putbinaryfile file, filename
      FileUtils.rm file if stv["delete"]["local"]
    end
  end
  
  def disconnect
    close @down
  end
  
  def self.disconnect
    @@up.close if @@up
  end
end

