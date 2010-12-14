require './constants.rb'
require './server.rb'

module Variables
  include Constants

  def setup
    @servers = const["servers"].collect do |details|
      Server.new details
    end
  
    @server = @servers.first
    @map = const["maps"].first
  
    @players = {}
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