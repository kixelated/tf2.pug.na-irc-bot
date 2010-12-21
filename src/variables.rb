require_relative 'constants'

require_relative 'model/server'

module Variables
  include Constants

  def setup
    @servers = const["servers"].collect do |details|
      Server.new details["name"], details["ip"], details["port"], details["password"], details["rcon"]
    end
  
    @server = @servers.first
    @prev_maps = []
    next_map
  
    @signups = {}
    @auth = {} # A backup of nicks to authnames in case somebody disconnects during picking
    @spoken = {}
    @afk = []

    @teams = []
    @lookup = {}
    
    @last = nil
    @state = const["states"]["waiting"]
    @pick = 0
  end
end
