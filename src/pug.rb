require 'cinch'

require './logic/players.rb'
require './logic/picking.rb'
require './logic/state.rb'
require './logic/server.rb'

require './variables.rb'
require './util.rb'

class Pug
  include Cinch::Plugin
  
  include Variables
  include Utilities
  
  include PlayersLogic
  include PickingLogic
  include StateLogic
  include ServerLogic
  
  listen_to :channel, method: :channel
  listen_to :part, method: :remove
  listen_to :quit, method: :remove
  listen_to :nick, method: :nick
  
  match /add (.+)/i, method: :add
  match /remove/i, method: :remove
  match /list/i, method: :list
  match /players/i, method: :list
  match /need/i, method: :need
  match /afk/i, method: :afk
  
  match /pick ([\S]+) ([\S]+)/i, method: :pick
  match /captain/i, method: :captain
  match /format/i, method: :format
  
  match /stats ([\S]+)/i, method: :stats
  match /nick/i, method: :update_nick
  
  match /map/i, method: :map
  match /server/i, method: :server
  match /ip/i, method: :server
  match /last/i, method: :last
  
  match /man/i, method: :help
  match /mumble/i, method: :mumble
  
  match /force ([\S]+) (.+)/i, method: :admin_force
  match /replace ([\S]+) ([\S]+)/i, method: :admin_replace
  
  match /changemap ([\S]+)/i, method: :admin_changemap
  match /changeserver ([\S]+) ([\S]+) ([\S]+) ([\S]+)/i, method: :admin_changeserver
  match /nextmap/i, method: :admin_nextmap
  match /nextserver/i, method: :admin_nextserver
  match /reset/i, method: :admin_reset
  match /endgame/i, method: :admin_endgame

  def initialize *args
    super
    setup # variables.rb 
  end
  
  def channel m
    @spoken[m.user.nick] = Time.now
    
    if @afk.delete m.user.nick and @afk.empty?
      attempt_delay # logic/state.rb
    end
  end
  
  def nick m
    list_players if replace_player m.user.last_nick, m.user.nick
  end

  # !add
  def add m, args
    if add_player m.user.nick, args.split(/ /) # logic/players.rb
      list_players # logic/players.rb
      attempt_afk # logic/state.rb
    end
  end

  # !remove, (quit), (part)
  def remove m
    list_players if remove_player m.user.nick # logic/players.rb
  end
  
  # !list, !players
  def list m
    list_players # logic/players.rb
    list_players_detailed # logic/players.rb
  end
  
  # !need
  def need m
    list_classes_needed # logic/players.rb
  end

  # !pick
  def pick m, player, player_class
    pick_player m.user.nick, player, player_class # logic/picking.rb
  end
  
  # !captain
  def captain m
    list_captain m.user.nick # logic/picking.rb
  end
  
  # !format
  def format m
    list_format # logic/picking.rb
  end
  
  # !stats
  def stats m, user
    list_stats user # logic/players.rb
  end
  
  # !nick
  def update_nick m, nick
    update_player m.user, nick # logic/players.rb
  end
  
  # !mumble
  def mumble m
    message "The Mumble IP is: chi6.eoreality.net:64746 password: tf2pug"
    message advertisement
  end

  # !map
  def map m
    list_map # logic/server.rb
  end
  
  # !server
  def server m
    list_server # logic/server.rb
  end
  
  # !last
  def last m
    list_last # logic/server.rb
  end
  
  # !man
  def help m
    message "The avaliable commands are: !add, !remove, !list, !need, !pick, !captain, !mumble, !map, !server"
  end
  
  # !afk
  def afk m
    list_afk # logic/state.rb
  end

  # !changemap
  def admin_changemap m, map
    return unless require_admin m
    
    change_map map
    list_map
  end
  
  # changeserver
  def admin_changeserver m, ip, port, pass, rcon
    return unless require_admin m
    
    change_server ip, port, pass, rcon
    list_server
  end
  
  # !nextmap
  def admin_nextmap m
    return unless require_admin m
    
    next_map
    list_map
  end
  
  # !nextserver
  def admin_nextserver m
    return unless require_admin m
    
    next_server
    list_server
  end

  # !force
  def admin_force m, player, args
    return unless require_admin m
    
    if add_player User(player), args.split(/ /) # logic/players.rb
      list_players # logic/players.rb
      attempt_afk # logic/state.rb
    end
  end
  
  # !replace
  def admin_replace m, user, replacement
    return unless require_admin m
    
    list_players if replace_player User(user), User(replacement) # logic/picking.rb
  end
  
  # !endgame
  def admin_endgame m
    return unless require_admin m
    
    end_game
    message "Game has been ended, please add up again."
  end
  
  # !reset
  def admin_reset m
    return unless require_admin m
    
    reset_game
    message "Game has been reset, please add up again."
  end
  
  def require_admin m
    return notice m.user, "That is an admin-only command." unless m.channel.opped? m.user
    true
  end

  def message msg
    BotManager.instance.msg const["irc"]["channel"], colourize(msg.to_s)
    false
  end
  
  def private user, msg
    BotManager.instance.msg user, msg
    false
  end

  def notice channel = const["irc"]["channel"], msg
    BotManager.instance.notice channel, msg
    false
  end
end
