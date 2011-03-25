require_relative 'constants'
require_relative 'logic/server'
require_relative 'model/match'

module Variables
  include Constants

  def setup
    DataMapper.finalize
    DataMapper.auto_migrate!
    
    state "waiting"
    
    @map = next_map
    
    @users = {}
    @spoken = {}
    
    @toadd = {}
    @toremove = []
    
    @show_list = 0
  end
  
  def end_game
    state "waiting"
    
    @map = next_map
    
    @users.reject! { |k, v| !@signups.key? k }
    @spoken.reject! { |k, v| !@signups.key? k }
    
    @toadd.reject! { |nick, classes| add_player User(nick), classes }
    @toremove.reject! { |nick| remove_player User(nick) }
  end
end
