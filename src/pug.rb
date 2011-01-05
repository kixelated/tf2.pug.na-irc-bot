require 'cinch'

require_relative 'variables'
require_relative 'util'

require_relative 'logic/players'
require_relative 'logic/picking'
require_relative 'logic/state'
require_relative 'logic/server'

class Pug
  include Cinch::Plugin
  
  include Variables
  include Utilities
  
  include PlayersLogic
  include PickingLogic
  include StateLogic
  include ServerLogic
  
  # events
  listen_to :channel, method: :event_channel
  listen_to :join, method: :event_join
  listen_to :part, method: :event_part
  listen_to :quit, method: :event_quit
  listen_to :nick, method: :event_nick
  
  timer 30, method: :event_timer
  
  # player-related commands
  match /add(?: (.+))?/i, method: :command_add
  match /remove/i, method: :command_remove
  match /list/i, method: :command_list
  match /players/i, method: :command_list
  match /need/i, method: :command_need
  match /afk/i, method: :command_afk
  match /stats(?: ([\S]+))?/i, method: :command_stats
  match /nick(?: ([\S]+))?/i, method: :command_nick
  match /reward/i, method: :command_reward

  # picking-related commands
  match /pick(?: ([\S]+) ([\S]+))?/i, method: :command_pick
  match /random(?: ([\S]+))?/i, method: :command_random
  match /captain/i, method: :command_captain
  match /format/i, method: :command_format

  # server-related commands
  match /map/i, method: :command_map
  match /server/i, method: :command_server
  match /ip/i, method: :command_server
  match /last/i, method: :command_last
  match /mumble/i, method: :command_mumble
  match /rotation/i, method: :command_rotation
  match /stv/i, method: :command_stv  
  match /status/i, method: :command_status
  
  # misc commands
  match /man/i, method: :command_help
  
  # admin commands
  match /force ([\S]+) (.+)/i, method: :admin_force
  match /replace ([\S]+) ([\S]+)/i, method: :admin_replace
  match /changemap ([\S]+)/i, method: :admin_changemap
  match /nextmap/i, method: :admin_nextmap
  match /nextserver/i, method: :admin_nextserver
  match /reset/i, method: :admin_reset
  match /endgame/i, method: :admin_endgame
  match /debug/i, method: :admin_debug
  match /quit/i, method: :admin_quit
  match /restrict ([\S]+) (.+)/i, method: :admin_restrict
  match /auth/i, method: :admin_auth
  match /cookie(?: ([\S]+))?/i, method: :admin_cookie
  
  def initialize *args
    super
    setup # variables.rb 
  end
  
  # Events
  def event_channel m
    update_spoken m.user # logic/state.rb
  end
  
  def event_join m
    reward_player m.user # logic/players.rb
  end
  
  def event_part m
    command_remove m
  end
  
  def event_quit m
    command_remove m
  end
  
  def event_nick m
    return unless @signups.key? m.user.nick 
    list_players if replace_player m.user.last_nick, m.user # logic/player.rb
  end
  
  def event_timer
    update_restrictions
  end

  # Player-related commands
  # !add
  def command_add m, classes
    return notice(m.user, "Add to the pug: !add <class1> <class2> <etc>") unless classes
  
    if add_player m.user, classes.split(/ /) # logic/players.rb
      list_players # logic/players.rb
      attempt_afk # logic/state.rb
    end
  end

  # !remove
  def command_remove m
    list_players if remove_player m.user.nick # logic/players.rb
  end
  
  # !list, !players
  def command_list m
    list_players # logic/players.rb
    list_players_detailed # logic/players.rb
  end
  
  # !need
  def command_need m
    list_classes_needed if can_add? # logic/players.rb
  end
  
  # !stats
  def command_stats m, user
    if user
      list_stats User(user) # logic/players.rb
    else
      list_stats m.user # logic/players.rb
    end
  end
  
  # !afk
  def command_afk m
    list_afk # logic/state.rb
  end
  
  # !nick
  def command_nick m, nick
    return notice(m.user, "Change you name in the database: !nick <newname>") unless nick
  
    update_player m.user, nick # logic/players.rb
  end
  
  # !reward
  def command_reward m
    m.user.refresh unless m.user.authed?
    explain_reward m.user unless reward_player m.user
  end
  
  # Picking-related commands
  # !pick
  def command_pick m, player, player_class
    return notice(m.user, "Pick a player for your team: !pick <name> <class> OR !pick <num> <class>") unless player and player_class
  
    pick_player m.user, player, player_class # logic/picking.rb
  end
  
  # !random
  def command_random m, clss
    return notice(m.user, "Pick a random player for a class: !random <class>") unless clss
  
    pick_random m.user, clss # logic/picking.rb
  end
  
  # !captain
  def command_captain m
    list_captain m.user # logic/picking.rb
  end
  
  # !format
  def command_format m
    list_format # logic/picking.rb
  end

  # Server-related commands
  # !mumble
  def command_mumble m
    list_mumble # logic/server.rb
  end

  # !map
  def command_map m
    list_map # logic/server.rb
  end
  
  # !server
  def command_server m
    list_server # logic/server.rb
  end
  
  # !last
  def command_last m
    list_last # logic/server.rb
  end
  
  # !rotation
  def command_rotation m
    list_rotation # logic/server.rb
  end
  
  # !stv
  def command_stv m
    list_stv # logic/server.rb
    update_stv unless @updating # logic/server.rb
  end
  
  # !status 
  def command_status m
    list_status # logic/server.rb
  end

  # Misc commands
  # !man
  def command_help m
    message "Player related commands: !add, !remove, !list, !need, !afk, !stats, !nick"
    message "Captain related comands: !pick, !random, !captain, !format"
    message "Server related commands: !ip, !map, !mumble, !last, !rotation, !stv"
  end

  # Admin commands
  # !changemap
  def admin_changemap m, map
    return unless require_admin m.user
    
    change_map map
    list_map
  end
  
  # !nextmap
  def admin_nextmap m
    return unless require_admin m.user
    
    next_map
    list_map
  end
  
  # !nextserver
  def admin_nextserver m
    return unless require_admin m.user
    
    next_server
    list_server
  end

  # !force
  def admin_force m, player, classes
    return unless require_admin m.user
    
    if add_player User(player), classes.split(/ /) # logic/players.rb
      list_players # logic/players.rb
      attempt_afk # logic/state.rb
    end
  end
  
  # !replace
  def admin_replace m, user, replacement
    return unless require_admin m.user
    
    list_players if replace_player user, User(replacement) # logic/picking.rb
  end
  
  # !endgame
  def admin_endgame m
    return unless require_admin m.user
    
    end_game
    message "Game has been ended, please add up again."
  end
  
  # !reset
  def admin_reset m
    return unless require_admin m.user
    
    reset_game
    message "Game has been reset, please add up again."
  end

  # !debug
  def admin_debug m
    return unless require_admin m.user
    
    @debug = !@debug
    message "Debug state is #{ @debug }."
  end
  
  # !quit
  def admin_quit m
    return unless require_admin m.user
  
    BotManager.instance.quit
  end
  
  # !restrict
  def admin_restrict m, nick, duration
    return unless require_admin m.user
    
    restrict_player m.user, nick, duration
  end
  
  # !auth
  def admin_auth m
    return unless require_admin m.user
  
    bot.msg Constants.const["irc"]["auth_serv"], "AUTH #{ Constants.const["irc"]["auth"] } #{ Constants.const["irc"]["auth_password"] }"
  end
  
  # !cookie
  def admin_cookie m, pass
    return unless require_admin m.user
    
    unless pass
      bot.msg Constants.const["irc"]["auth_serv"], "AUTHCOOKIE #{ Constants.const["irc"]["auth"] }"
    else
      bot.msg Constants.const["irc"]["auth_serv"], "COOKIE #{ Constants.const["irc"]["auth"] } #{ pass }"
    end
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