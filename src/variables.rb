require './constants.rb'

module Variables
  include Constants

  def setup
    @server = const["servers"].first
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