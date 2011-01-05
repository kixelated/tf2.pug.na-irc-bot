require 'net/ftp'
require 'fileutils'

require_relative 'constants'

class STV
  include Constants

  def initialize server
    @server = server
  end

  def open details
    Net::FTP.open(details["ip"], details["password"], details["user"]).tap do |conn|
      conn.passive = true
      conn.chdir details["dir"] if details["dir"]
    end
  end
  
  def close conn
    conn.close if conn
  end
  
  def demos
    @down.nlst.reject { |filename| !(filename =~ /.+\.dem/) }
  end
  
  def update
    demos.each do |filename|
      file = const["stv"]["path"] + filename
    
      @down.getbinaryfile filename, file
      @down.delete filename if const["stv"]["delete"]["remote"]
      @up.putbinaryfile file, filename
      FileUtils.rm file if const["stv"]["delete"]["local"]
    end
  end
  
  def connect
    @up = open const["stv"]["ftp"]
    @down = open @server
  end
  
  def disconnect
    close @up
    close @down
  end
end