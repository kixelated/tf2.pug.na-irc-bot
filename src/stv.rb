require 'net/ftp'
require 'fileutils'

require_relative 'constants'

class STV
  include Constants

  def initialize server
    @server = server
  end

  def open details
    Net::FTP.new.tap do |conn|
      conn.set_socket TCPSocket.new(details["ip"], details["port"], const["internet"]["local_host"])
      conn.login details["user"], details["password"]
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

