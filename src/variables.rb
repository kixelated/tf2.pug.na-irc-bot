require_relative 'constants'

module Variables
  include Constants

  def setup
    @users = {}
    @spoken = {}
    
    @toadd = {}
    @toremove = []
    
    @show_list = 0
  end
  
  def end_game
    @users.reject! { |k, v| !@signups.key? k }
    @spoken.reject! { |k, v| !@signups.key? k }
    
    @toadd.reject! { |nick, classes| add_player User(nick), classes }
    @toremove.reject! { |nick| remove_player User(nick) }
  end
end
