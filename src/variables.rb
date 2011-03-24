require_relative 'constants'
require_relative 'logic/server'
require_relative 'model/match'

module Variables
  include Constants

  def setup
    DataMapper.finalize
    DataMapper.auto_migrate!
    
    @map = next_map
  
    @signups = {}
    @auth = {}
    @spoken = {}
    @afk = []
    
    @toadd = {}
    @toremove = []

    @teams = []
    @pick_order = []
    @lookup = {}
    
    @state = const["states"]["waiting"]
    @pick = 0

    @show_list = 0
  end
  
  def end_game
    @teams.clear
    @lookup.clear

    state "waiting"
    @pick = 0
    @pick_order = []
    
    @auth.reject! { |k, v| !@signups.key? k }
    @spoken.reject! { |k, v| !@signups.key? k }
    
    @toadd.each { |nick, classes| add_player User(nick), classes }
    @toremove.each { |nick| remove_player User(nick) }
    
    @toadd.clear
    @toremove.clear

    @map = next_map
  end
end
