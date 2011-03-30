require 'cinch'

require 'tf2pug/constants'
require 'tf2pug/bot/manager'

module Irc
  def require_admin m
    return notice m.user, "That is an admin-only command." unless m.channel.opped? m.user
    true
  end

  def message user = Constants.irc['channel'], msg
    BotManager.instance.msg user, colourize(msg.to_s) if user
    false
  end
  
  def notice user = Constants.irc['channel'], msg
    BotManager.instance.notice channel, msg if user
    false
  end
  
  Colours = {
    white: 0,
    black: 1,
    navy: 2,
    green: 3,
    red: 4,
    brown: 5,
    purple: 6,
    orange: 7,
    yellow: 8,
    lime: 9,
    teal: 10,
    aqua: 11,
    blue: 12,
    pink: 13,
    grey: 14,
    lgrey: 15,
    home: 11, # Team colours
    away: 4,
    scout: 0, # Class colours
    soldier: 0,
    demo: 0,
    medic: 0,
    captain: 0
  }

  def colour_start fore, back = 0
    "\x03#{ fore.to_s.rjust(2, "0") }" + "#{ ",#{ back.to_s.rjust(2, "0") }" if back != 0 }"
  end
  
  def colour_end
    "\x03"
  end
  
  def colourize msg, fore = :white, back = :black
    fore = if Colours[fore]; Colours[fore]; else; :white; end
    back = if Colours[back]; Colours[back]; else; :black; end
     
    output = msg.to_s.gsub(/\x03\d.*?\x03/) { |str| "#{ colour_end }#{ str }#{ colour_start(fore, back) }" }
    "#{ colour_start(fore, back) }#{ output }#{ colour_end }"
  end 
  
  def bold msg
    "\x02#{ msg.to_s }\x02"
  end
  
  def rjust msg, justify = 15
    msg.to_s.rjust(justify)
  end
end
