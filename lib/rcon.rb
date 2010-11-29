require 'socket'

#
# RCon is a module to work with Quake 1/2/3, Half-Life, and Half-Life
# 2 (Source Engine) RCon (Remote Console) protocols.
#
# Version:: 0.2.0
# Author:: Erik Hollensbe <erik@hollensbe.org>
# License:: BSD
# Contact:: erik@hollensbe.org
# Copyright:: Copyright (c) 2005-2006 Erik Hollensbe
#
# The relevant modules to query RCon are in the RCon::Query namespace,
# under RCon::Query::Original (for Quake 1/2/3 and Half-Life), and
# RCon::Query::Source (for HL2 and CS: Source, and other Source Engine
# games). The RCon::Packet namespace is used to manage complex packet
# structures if required. The Original protocol does not require
# this, but Source does.
#
# Usage is fairly simple:
#
# # Note: Other classes have different constructors
#
# rcon = RCon::Query::Source.new("10.0.0.1", 27015)
#
# rcon.auth("foobar") # source only
#
# rcon.command("mp_friendlyfire") => "mp_friendlyfire = 1"
#
# rcon.cvar("mp_friendlyfire") => 1
#
#--
#
# The compilation of software known as rcon.rb is distributed under the
# following terms:
# Copyright (C) 2005-2006 Erik Hollensbe. All rights reserved.
#
# Redistribution and use in source form, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#++


class RCon
  class Packet
    # placeholder so ruby doesn't bitch
  end
  class Query

    #
    # Convenience method to scrape input from cvar output and return that data.
    # Returns integers as a numeric type if possible.
    #
    # ex: rcon.cvar("mp_friendlyfire") => 1
    #

    def cvar(cvar_name)
      response = command(cvar_name)
      match = /^.+?\s(?:is|=)\s"([^"]+)".*$/.match response
      match = match[1]
      if /\D/.match match
        return match
      else
        return match.to_i
      end
    end
  end
end

#
# RCon::Packet::Source generates a packet structure useful for
# RCon::Query::Source protocol queries.
#
# This class is primarily used internally, but is available if you
# want to do something more advanced with the Source RCon
# protocol.
#
# Use at your own risk.
#

class RCon::Packet::Source
  # execution command
  COMMAND_EXEC = 2
  # auth command
  COMMAND_AUTH = 3
  # auth response
  RESPONSE_AUTH = 2
  # normal response
  RESPONSE_NORM = 0
  # packet trailer
  TRAILER = "\x00\x00"
  
  # size of the packet (10 bytes for header + string1 length)
  attr_accessor :packet_size
  # Request Identifier, used in managing multiple requests at once
  attr_accessor :request_id
  # Type of command, normally COMMAND_AUTH or COMMAND_EXEC. In response packets, RESPONSE_AUTH or RESPONSE_NORM
  attr_accessor :command_type
  # First string, the only used one in the protocol, contains
  # commands and responses. Null terminated.
  attr_accessor :string1
  # Second string, unused by the protocol. Null terminated.
  attr_accessor :string2
  
  #
  # Generate a command packet to be sent to an already
  # authenticated RCon connection. Takes the command as an
  # argument.
  # 
  def command(string)
    @request_id = rand(1000)
    @string1 = string
    @string2 = TRAILER
    @command_type = COMMAND_EXEC

    @packet_size = build_packet.length

    return self
  end
  
  #
  # Generate an authentication packet to be sent to a newly
  # started RCon connection. Takes the RCon password as an
  # argument.
  #
  def auth(string)
    @request_id = rand(1000)
    @string1 = string
    @string2 = TRAILER
    @command_type = COMMAND_AUTH
    
    @packet_size = build_packet.length
    
    return self
  end
  
  #
  # Builds a packet ready to deliver, without the size prepended.
  # Used to calculate the packet size, use #to_s to get the packet
  # that srcds actually needs.
  #
  def build_packet
    return [@request_id, @command_type, @string1, @string2].pack("VVa#{@string1.length}a2")
  end

  # Returns a string representation of the packet, useful for
  # sending and debugging. This include the packet size.
  def to_s
    packet = build_packet
    @packet_size = packet.length
    return [@packet_size].pack("V") + packet
  end

end

#
# RCon::Query::Original queries Quake 1/2/3 and Half-Life servers
# with the rcon protocol. This protocol travels over UDP to the
# game server port, and requires an initial authentication step,
# the information of which is provided at construction time.
#
# Some of the work here (namely the RCon packet structure) was taken
# from the KKRcon code, which is written in perl.
#
# One query per authentication is allowed.
#

class RCon::Query::Original < RCon::Query
  # HLDS-Based Servers
  HLDS         = "l"
  # QuakeWorld/Quake 1 Servers
  QUAKEWORLD   = "n"
  # Quake 2/3 Servers
  NEWQUAKE     = ""
  
  # Request to be sent to server
  attr_reader :request
  # Response from server
  attr_reader :response
  # Challenge ID (served by server-side of connection)
  attr_reader :challenge_id
  # UDPSocket object
  attr_reader :socket
  # Host of connection
  attr_reader :host
  # Port of connection
  attr_reader :port
  # RCon password
  attr_reader :password
  # type of server
  attr_reader :server_type
  
  #
  # Creates a RCon::Query::Original object for use.
  #
  # The type (the default of which is HLDS), has multiple possible
  # values:
  # 
  # HLDS - Half Life 1 (will not work with older versions of HLDS)
  #
  # QUAKEWORLD - QuakeWorld/Quake 1
  #
  # NEWQUAKE - Quake 2/3 (and many derivatives)
  #

  def initialize(host, port, password, type=HLDS)
    @host = host
    @port = port
    @password = password
    @server_type = type
  end
  
  #
  # Sends a request given as the argument, and returns the
  # response as a string.
  #
  def command(request)
    @request = request
    @challenge_id = nil

    establish_connection

    @socket.print "\xFF" * 4 + "challenge rcon\n\x00"
    
    tmp = retrieve_socket_data
    challenge_id = /challenge rcon (\d+)/.match tmp
    if challenge_id
      @challenge_id = challenge_id[1]
    end

    if @challenge_id.nil?
      raise RCon::NetworkException.new("RCon challenge ID never returned: wrong rcon password?")
    end

    @socket.print "\xFF" * 4 + "rcon #{@challenge_id} \"#{@password}\" #{@request}\n\x00"
    @response = retrieve_socket_data

    @response.sub! /^\xFF\xFF\xFF\xFF#{@server_type}/, ""
    @response.sub! /\x00+$/, ""
    
    return @response
  end
  
  #
  # Disconnects the RCon connection.
  #
  def disconnect
    if @socket
      @socket.close
      @socket = nil
    end
  end
  
  protected
  
  #
  # Establishes the connection.
  #
  def establish_connection
    if @socket.nil?
      @socket = UDPSocket.new
      @socket.connect(@host, @port)
    end
  end
  
  #
  # Generic method to pull data from the socket.
  #

  def retrieve_socket_data
    return "" if @socket.nil?

    retval = ""
    loop do 
      break unless IO.select([@socket], nil, nil, 10)
      packet = @socket.recv(8192)
      retval << packet
      break if packet.length < 8192
    end
    
    return retval
  end

end

#
# RCon::Query::Source sends queries to a "Source" Engine server,
# such as Half-Life 2: Deathmatch, Counter-Strike: Source, or Day
# of Defeat: Source.
#
# Note that one authentication packet needs to be sent to send
# multiple commands. Sending multiple authentication packets may
# damage the current connection and require it to be reset.
#
# Note: If the attribute 'return_packets' is set to true, the full
# RCon::Packet::Source object is returned, instead of just a string
# with the headers stripped. Useful for debugging.
#

class RCon::Query::Source < RCon::Query
  # RCon::Packet::Source object that was sent as a result of the last query
  attr_reader :packet
  # TCPSocket object
  attr_reader :socket
  # Host of connection
  attr_reader :host
  # Port of connection
  attr_reader :port
  # Authentication Status
  attr_reader :authed
  # return full packet, or just data?
  attr_accessor :return_packets
  
  #
  # Given a host and a port (dotted-quad or hostname OK), creates
  # a RCon::Query::Source object. Note that this will still
  # require an authentication packet (see the auth() method)
  # before commands can be sent.
  #

  def initialize(host, port)
    @host = host
    @port = port
    @socket = nil
    @packet = nil
    @authed = false
    @return_packets = false
  end
  
  #
  # See RCon::Query#cvar.
  # 
  
  def cvar(cvar_name)
    return_packets = @return_packets
    @return_packets = false
    response = super
    @return_packets = return_packets
    return response
  end

  #
  # Sends a RCon command to the server. May be used multiple times
  # after an authentication is successful. 
  #
  # See the class-level documentation on the 'return_packet' attribute
  # for return values. The default is to return a string containing
  # the response.
  #
  
  def command(command)
    
    if ! @authed
      raise RCon::NetworkException.new("You must authenticate the connection successfully before sending commands.")
    end

    @packet = RCon::Packet::Source.new
    @packet.command(command)

    @socket.print @packet.to_s
    rpacket = build_response_packet

    if rpacket.command_type != RCon::Packet::Source::RESPONSE_NORM
      raise RCon::NetworkException.new("error sending command: #{rpacket.command_type}")
    end

    if @return_packets
      return rpacket
    else
      return rpacket.string1
    end
  end
  
  #
  # Requests authentication from the RCon server, given a
  # password. Is only expected to be used once.
  #
  # See the class-level documentation on the 'return_packet' attribute
  # for return values. The default is to return a true value if auth
  # succeeded.
  #
  
  def auth(password)
    establish_connection

    @packet = RCon::Packet::Source.new
    @packet.auth(password)

    @socket.print @packet.to_s
    # on auth, one junk packet is sent
    rpacket = nil
    2.times { rpacket = build_response_packet }

    if rpacket.command_type != RCon::Packet::Source::RESPONSE_AUTH
      raise RCon::NetworkException.new("error authenticating: #{rpacket.command_type}")
    end

    @authed = true
    if @return_packets
      return rpacket
    else
      return true
    end
  end

  alias_method :authenticate, :auth
  
  #
  # Disconnects from the Source server.
  #
  
  def disconnect
    if @socket
      @socket.close
      @socket = nil
      @authed = false
    end
  end
  
  protected
  
  #
  # Builds a RCon::Packet::Source packet based on the response
  # given by the server. 
  #
  def build_response_packet
    rpacket = RCon::Packet::Source.new
    total_size = 0
    request_id = 0
    type = 0
    response = ""
    message = ""
    

    loop do
      break unless IO.select([@socket], nil, nil, 10)

      #
      # TODO: clean this up - read everything and then unpack.
      #

      tmp = @socket.recv(14)
      if tmp.nil?
        return nil
      end
      size, request_id, type, message = tmp.unpack("VVVa*")
      total_size += size
      
      # special case for authentication
      break if message.sub! /\x00\x00$/, ""

      response << message

      # the 'size - 10' here accounts for the fact that we've snarfed 14 bytes,
      # the size (which is 4 bytes) is not counted, yet represents the rest
      # of the packet (which we have already taken 10 bytes from)

      tmp = @socket.recv(size - 10)
      response << tmp
      response.sub! /\x00\x00$/, ""
    end
    
    rpacket.packet_size = total_size
    rpacket.request_id = request_id
    rpacket.command_type = type
    
    # strip nulls (this is actually the end of string1 and string2)
    rpacket.string1 = response.sub /\x00\x00$/, ""
    return rpacket
  end
  
  # establishes a connection to the server.
  def establish_connection
    if @socket.nil?
      @socket = TCPSocket.new(@host, @port)
    end
  end
  
end

# Exception class for network errors
class RCon::NetworkException < Exception
end
