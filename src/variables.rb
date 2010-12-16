require './constants.rb'
require './server.rb'

module Variables
  include Constants

  def setup
    @servers = const["servers"].collect do |details|
      Server.new details["name"], details["ip"], details["port"], details["password"], details["rcon"]
    end
  
    @server = @servers.first
    @map = const["maps"].first
  
    @players = {}
    @authnames = {}
    @spoken = {}
    @afk = []

    @captains = []
    @teams = []
    @lookup = {}
    
    @last = nil
    @state = const["states"]["waiting"]
    @pick = 0
  end
end
