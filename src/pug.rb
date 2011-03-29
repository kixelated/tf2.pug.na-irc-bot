require 'cinch'

require_relative 'bot/irc'
require_relative 'bot/manager'

require_relative 'logic/afk'
require_relative 'logic/map'
require_relative 'logic/picking'
require_relative 'logic/server'
require_relative 'logic/signup'
require_relative 'logic/state'
require_relative 'logic/stats'
require_relative 'logic/user'

class Pug
  include Cinch::Plugin
  
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
  match /add(?: (.+))?/i, method: :command_add
  match /remove/i, method: :command_remove
  match /list/i, method: :command_list
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
  match /code/i, method: :command_code
  
  # admin commands
  match /fadd ([\S]+) (.+)/i, method: :admin_forceadd
  match /fremove ([\S]+)/i, method: :admin_forceremove
  match /fpick ([\S]+) ([\S]+)/i, method: :admin_forcepick
  match /replace ([\S]+) ([\S]+)/i, method: :admin_replace
  match /restrict ([\S]+) (.+)/i, method: :admin_restrict
  match /authorize ([\S]+)/i, method: :admin_authorize
  match /cookie(?: ([\S]+))?/i, method: :admin_cookie
  match /fmap ([\S]+) ([\S]+)/i, method: :admin_forcemap
  match /nextmap/i, method: :admin_nextmap
  match /nextserver/i, method: :admin_nextserver
  match /reset/i, method: :admin_reset
  match /endgame/i, method: :admin_endgame
  match /quit/i, method: :admin_quit
  
  # Events
  def event_channel m
    AfkLogic::update_spoken m.user
  end
  
  def event_join m
    UserLogic::reward_player m.user
  end
  
  def event_part m
    command_remove m
  end
  
  def event_quit m
    command_remove m
  end
  
  def event_kick m
    SignupLogic::remove_player User(m.params[1])
  end
  
  def event_nick m
    SignupLogic::replace_player User(m.user.last_nick), m.user
  end
  
  def timer_list
    SignupLogic::list_signups if @show_list > 1
    @show_list = 0
  end
  
  def timer_restriction
    UserLogic::update_restrictions
  end

  # Player-related commands
  # !add
  def command_add m, classes
    return Irc::notice(m.user, "Add to the pug: !add <class1> <class2> <etc>") unless classes
  
    if SignupLogic::add_player m.user, classes.split(/ /)
      SignupLogic::list_signups_delay
      StateLogic::attempt_afk 
    end
  end

  # !remove
  def command_remove m
    SignupLogic::list_signups_delay if SignupLogic::remove_player m.user
  end
  
  # !list
  def command_list m
    SignupLogic::list_signups
  end
  
  # !need
  def command_need m
    SignupLogic::list_classes_needed if StateLogic::can_add?
  end
  
  # !stats
  def command_stats m, player
    if player; StatsLogic::list_stats User(player)
    else; StatsLogic::list_stats m.user
    end
  end
  
  # !afk
  def command_afk m
    AfkLogic::list_afk
  end
  
  # !nick
  def command_nick m, nick
    return Irc::notice(m.user, "Change you name in the database: !nick <newname>") unless nick
  
    UserLogic::update_nick m.user, nick
  end
  
  # !reward
  def command_reward m
    StatsLogic::reward_player m.user
  end
  
  # Picking-related commands
  # !pick
  def command_pick m, player, player_class
    return Irc::notice(m.user, "Pick a player for your team: !pick <name> <class> OR !pick <num> <class>") unless player and player_class
  
    PickingLogic::pick_player m.user, player, player_class
  end
  
  # !random
  def command_random m, clss
    return notice(m.user, "Pick a random player for a class: !random <class>") unless clss
  
    PickingLogic::pick_random m.user, clss 
  end
  
  # !captain
  def command_captain m
    PickingLogic::list_captain m.user 
  end
  
  # !format
  def command_format m
    PickingLogic::list_format 
  end

  # Server-related commands
  # !mumble
  def command_mumble m
    ServerLogic::list_mumble
  end

  # !map
  def command_map m
    MapLogic::list_map
  end
  
  # !server
  def command_server m
    ServerLogic::list_server
  end
  
  # !last
  def command_last m
    StateLogic::list_last
  end
  
  # !rotation
  def command_rotation m
    MapLogic::list_rotation
  end
  
  # !stv
  def command_stv m
    ServerLogic::list_stv
    ServerLogic::update_stv unless @updating
  end
  
  # !status 
  def command_status m
    ServerLogic::list_status
  end

  # Misc commands
  # !man
  def command_help m
    Irc::message "Player related commands: !add, !remove, !list, !need, !afk, !stats, !nick"
    Irc::message "Captain related comands: !pick, !random, !captain, !format"
    Irc::message "Server related commands: !ip, !map, !mumble, !last, !rotation, !stv"
  end
  
  # !code
  def command_code m
    Irc::message "IRC bot   : https://github.com/qpingu/tf2.pug.na-irc-bot"
    Irc::message "TF2 server: https://github.com/qpingu/tf2.pug.na-game-server"
  end

  # Admin commands
  # !fmap
  def admin_forcemap m, map, file
    return unless Irc::require_admin m
    
    MapLogic::change_map map, file
    MapLogic::list_map
  end
  
  # !nextmap
  def admin_nextmap m
    return unless Irc::require_admin m
    
    MapLogic::next_map
    MapLogic::list_map
  end
  
  # !nextserver
  def admin_nextserver m
    return unless Irc::require_admin m
    
    ServerLogic::next_server
    ServerLogic::list_server
  end

  # !fadd
  def admin_forceadd m, player, classes
    return unless Irc::require_admin m

    if SignupLogic::add_player User(player), classes.split(/ /) 
      SignupLogic::list_signups_delay
      StateLogic::attempt_afk 
    end
  end
  
  # !fremove
  def admin_forceremove m, player
    return unless Irc::require_admin m
    
    SignupLogic::list_signups_delay if SignupLogic::remove_player User(player)
  end
  
  # !fpick 
  def admin_forcepick m, player, player_class
    return unless Irc::require_admin m
  
    PickingLogic::pick_player User(PickingLogic::current_captain), User(player), player_class 
  end
  
  # !replace
  def admin_replace m, player, replacement
    return unless Irc::require_admin m
    
    SignupLogic::list_signups_delay if SignupLogic::replace_player User(player), User(replacement) 
  end
  
  # !endgame
  def admin_endgame m
    return unless Irc::require_admin m
    
    Irc::message "Game has been ended."
    
    StateLogic::end_game
    SignupLogic::list_signups
  end
  
  # !reset
  def admin_reset m
    return unless Irc::require_admin m
    
    Irc::message "Game has been reset, please add up again."
    
    StateLogic::reset_game
  end
  
  # !quit
  def admin_quit m
    return unless Irc::require_admin m
  
    BotManager.instance.quit
  end
  
  # !restrict
  def admin_restrict m, nick, duration
    return unless Irc::require_admin m
    
    UserLogic::restrict_player m.user, nick, duration
  end
  
  # !authorize
  def admin_authorize m, nick
    return unless Irc::require_admin m
    
    UserLogic::authorize_player m.user, nick
  end
  
  # !cookie
  def admin_cookie m, pass
    return unless Irc::require_admin m
    
    unless pass
      bot.msg Constants.irc['auth_serv'], "AUTHCOOKIE #{ Constants.irc['auth'] }"
    else
      bot.msg Constants.irc['auth_serv'], "COOKIE #{ Constants.irc['auth'] } #{ pass }"
    end
  end
  
  # !reload
  def admin_reload m
    return unless Irc::require_admin m
    
    Constants.load_config
  end
end
