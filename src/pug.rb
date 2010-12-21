require 'cinch'

require_relative 'logic/players'
require_relative 'logic/picking'
require_relative 'logic/state'
require_relative 'logic/server'

require_relative 'variables'
require_relative 'util'

class Pug
  include Cinch::Plugin
  
  include Variables
  include Utilities
  
  include PlayersLogic
  include PickingLogic
  include StateLogic
  include ServerLogic
  
  message "Player related commands: !add, !remove, !list, !need, !afk, !stats, !nick"
  message "Captain related comands: !pick, !random, !captain, !format, !list, !state"
  message "Server related commands: !ip, !map, !mumble, !last, !rotation"

  listen_to :channel, method: :channel
  listen_to :join, method: :join
  listen_to :part, method: :remove
  listen_to :quit, method: :remove
  listen_to :nick, method: :nick
  
  match /add (.+)/i, method: :add
  match /remove/i, method: :remove
  match /list/i, method: :list
  match /players/i, method: :list
  match /need/i, method: :need
  match /afk/i, method: :afk
  match /stats ([\S]+)/i, method: :stats
  match /nick/i, method: :update_nick
  
  match /pick ([\S]+) ([\S]+)/i, method: :pick
  match /random ([\S]+)/i, method: :random
  match /captain/i, method: :captain
  match /format/i, method: :format
  match /state/i, method: :state
  
  match /map/i, method: :map
  match /server/i, method: :server
  match /ip/i, method: :server
  match /last/i, method: :last
  match /mumble/i, method: :mumble
  match /rotation/i, method: :rotation
  
  match /man/i, method: :help
  
  match /force ([\S]+) (.+)/i, method: :admin_force
  match /replace ([\S]+) ([\S]+)/i, method: :admin_replace
  match /changemap ([\S]+)/i, method: :admin_changemap
  match /nextmap/i, method: :admin_nextmap
  match /nextserver/i, method: :admin_nextserver
  match /reset/i, method: :admin_reset
  match /endgame/i, method: :admin_endgame

  def initialize *args
    super
    setup # variables.rb 
  end
  
  def channel m
    update_spoken m.user.nick # logic/state.rb
  end
  
  def join m
    reward_player m.user.nick # logic/players.rb
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
    
    if state? "picking" and current_captain == m.user.nick
      list_players_numbers # logic/players.rb
    else
      list_players_detailed # logic/players.rb
    end
  end
  
  # !need
  def need m
    list_classes_needed if can_add? # logic/players.rb
  end

  # !pick
  def pick m, player, player_class
    pick_player m.user.nick, player, player_class # logic/picking.rb
  end
  
  # !random
  def random m, clss
    pick_random m.user.nick, clss # logic/picking.rb
  end
  
  # !captain
  def captain m
    list_captain m.user.nick # logic/picking.rb
  end
  
  # !format
  def format m
    list_format # logic/picking.rb
  end
  
  # !state
  def state m
    list_state # logic/state.rb
  end
  
  # !stats
  def stats m, user
    list_stats user.nick # logic/players.rb
  end
  
  # !nick
  def update_nick m, nick
    update_player m.user.nick, nick # logic/players.rb
  end
  
  # !mumble
  def mumble m
    list_mumble # logic/server.rb
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
  
  def rotation m
    list_rotation # logic/server.rb
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
    return unless require_admin m.user
    
    change_map map
    list_map
  end
  
  # !nextmap
  def admin_nextmap m
    return unless require_admin m.user.nick
    
    next_map
    list_map
  end
  
  # !nextserver
  def admin_nextserver m
    return unless require_admin m.user.nick
    
    next_server
    list_server
  end

  # !force
  def admin_force m, player, args
    return unless require_admin m.user.nick
    
    if add_player User(player), args.split(/ /) # logic/players.rb
      list_players # logic/players.rb
      attempt_afk # logic/state.rb
    end
  end
  
  # !replace
  def admin_replace m, user, replacement
    return unless require_admin m.user.nick
    
    list_players if replace_player User(user), User(replacement) # logic/picking.rb
  end
  
  # !endgame
  def admin_endgame m
    return unless require_admin m.user.nick
    
    end_game
    message "Game has been ended, please add up again."
  end
  
  # !reset
  def admin_reset m
    return unless require_admin m.user.nick
    
    reset_game
    message "Game has been reset, please add up again."
  end
  
  def require_admin user
    return notice user, "That is an admin-only command." unless Channel(const["irc"]["channel"]).opped? user
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
