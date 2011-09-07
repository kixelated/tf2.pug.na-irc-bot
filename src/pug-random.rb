require 'cinch'

require_relative 'variables'
require_relative 'util'

require_relative 'logic/players-random'
require_relative 'logic/picking-random'
require_relative 'logic/state'
require_relative 'logic/server'

class Pug
  include Cinch::Plugin
  
  include Variables
  include Utilities
  
  include PlayersRandomLogic
  include PickingRandomLogic
  include StateLogic
  include ServerLogic
  
  # events
  listen_to :channel, method: :event_channel
  listen_to :join, method: :event_join
  listen_to :part, method: :event_part
  listen_to :quit, method: :event_quit
  listen_to :kick, method: :event_kick
  listen_to :nick, method: :event_nick
  
  timer 1, method: :timer_list
  timer 30, method: :timer_restriction
  
  # player-related commands
  match /add(?: (\w+))?/i, method: :command_add
  match /remove/i, method: :command_remove
  match /list/i, method: :command_players
  match /players/i, method: :command_players
  match /need/i, method: :command_need
  match /afk/i, method: :command_afk
  match /stats(?: ([\S]+))?/i, method: :command_stats
  match /nick(?: ([\S]+))?/i, method: :command_nick
  match /reward/i, method: :command_reward

  # server-related commands
  match /map/i, method: :command_map
  match /server/i, method: :command_server
  match /ip/i, method: :command_server
  match /last/i, method: :command_last
  match /logs/i, method: :command_logs
  match /mumble/i, method: :command_mumble
  match /rotation/i, method: :command_rotation
  match /stv/i, method: :command_stv  
  match /status/i, method: :command_status
  
  # misc commands
  match /man/i, method: :command_help
  match /code/i, method: :command_code
  
  # admin commands
  match /fadd ([\S]+) (.+)/i, method: :admin_forceadd
  match /fremove ([\S]+)/i, method: :admin_forceremove
  match /replace ([\S]+) ([\S]+)/i, method: :admin_replace
  match /restrict ([\S]+) (.+)/i, method: :admin_restrict
  match /authorize ([\S]+)/i, method: :admin_authorize
  match /cookie(?: ([\S]+))?/i, method: :admin_cookie
  match /fmap ([\S]+) ([\S]+)/i, method: :admin_forcemap
  match /nextmap/i, method: :admin_nextmap
  match /nextserver/i, method: :admin_nextserver
  match /reset/i, method: :admin_reset
  match /endgame/i, method: :admin_endgame
  match /reload/i, method: :admin_reload
  match /quit/i, method: :admin_quit
  
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
  
  def event_kick m
    remove_player m.params[1]
  end
  
  def event_nick m
    replace_player! m.user.last_nick, m.user # logic/player.rb
  end
  
  def timer_list
    list_players if @show_list > 1
    @show_list = 0
  end
  
  def timer_restriction
    update_restrictions
  end

  # Player-related commands
  # !add
  def command_add m, tf_class
    return notice(m.user, "Add to the pug: !add <class>") unless tf_class
  
    if add_player m.user, [ tf_class ]
      list_players_delay
      attempt_afk 
    end
  end

  # !remove
  def command_remove m
    list_players_delay if remove_player m.user.nick # logic/players.rb
  end
  
  # !players, !list
  def command_players m
    list_players # logic/players.rb
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
  
    update_nick m.user, nick # logic/players.rb
  end
  
  # !reward
  def command_reward m
    m.user.refresh unless m.user.authed?
    explain_reward m.user unless reward_player m.user
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
  
  # !logs
  def command_logs m
    list_logs # logic/server.rb
    update_logs unless @updating # logic/server.rb
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
    message "Server related commands: !ip, !map, !mumble, !last, !rotation, !stv"
  end
  
  # !code
  def command_code m
    message "IRC bot    : https://github.com/qpingu/tf2.pug.na-irc-bot"
    message "TF2 server : https://github.com/qpingu/tf2.pug.na-game-server"
  end

  # Admin commands
  # !fmap
  def admin_forcemap m, map, file
    return unless require_admin m
    
    change_map map, file
    list_map
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

  # !fadd
  def admin_forceadd m, player, tf_class
    return unless require_admin m

    if add_player! User(player), [ tf_class ] # logic/players.rb
      list_players_delay
      attempt_afk 
    end
  end
  
  # !fremove
  def admin_forceremove m, player
    return unless require_admin m
    
    list_players_delay if remove_player! player
  end
  
  # !replace
  def admin_replace m, nick, replacement
    return unless require_admin m
    
    list_players_delay if replace_player! nick, User(replacement) # logic/picking.rb
  end
  
  # !endgame
  def admin_endgame m
    return unless require_admin m
    
    message "Game has been ended."
    
    end_game
    list_players
  end
  
  # !reset
  def admin_reset m
    return unless require_admin m
    
    reset_game
    message "Game has been reset, please add up again."
  end

  # !debug
  def admin_debug m
    return unless require_admin m
    
    message "Signups: #{ @signups }"
    message "Teams: #{ @teams }"
  end
  
  # !quit
  def admin_quit m
    return unless require_admin m
  
    BotManager.instance.quit
  end
  
  # !restrict
  def admin_restrict m, nick, duration
    return unless require_admin m
    
    restrict_player m.user, nick, duration
  end
  
  # !authorize
  def admin_authorize m, nick
    return unless require_admin m
    
    authorize_player m.user, nick
  end
  
  # !cookie
  def admin_cookie m, pass
    return unless require_admin m
    
    unless pass
      bot.msg Constants.const["irc"]["auth_serv"], "AUTHCOOKIE #{ Constants.const["irc"]["auth"] }"
    else
      bot.msg Constants.const["irc"]["auth_serv"], "COOKIE #{ Constants.const["irc"]["auth"] } #{ pass }"
    end
  end
  
  # !reload
  def admin_reload m
    return unless require_admin m
    
    Constants.load_config
    Constants.calculate
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
