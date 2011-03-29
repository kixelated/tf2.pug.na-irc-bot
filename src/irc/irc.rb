require 'cinch'

require_relative '../constants'
require_relative 'botManager'

module Irc
  def require_admin m
    return notice m.user, "That is an admin-only command." unless m.channel.opped? m.user
    true
  end

  def message msg
    BotManager.instance.msg Constants.irc['channel'], colourize(msg.to_s)
    false
  end

  def privmsg user, msg
    BotManager.instance.msg user, msg
    false
  end

  def notice channel, msg
    BotManager.instance.notice channel, msg
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
    home: 11,
    away: 4
  }

  def colour_start fore, back = 0
    "\x03#{ fore.to_s.rjust(2, "0") }" + "#{ ",#{ back.to_s.rjust(2, "0") }" if back != 0 }"
  end
  
  def colour_end
    "\x03"
  end
  
  def colourize msg, fore = :white, back = :black
    output = msg.to_s.gsub(/\x03\d.*?\x03/) { |str| "#{ colour_end }#{ str }#{ colour_start(Colours[fore], Colours[back]) }" }
    "#{ colour_start(Colours[fore], Colours[back]) }#{ output }#{ colour_end }"
  end 
 
  def team_colourize msg, home, back = :black
    team = if home; :home; else; :away; end
    colourize msg, team, back
  end
  
  def bold msg
    "\x02#{ msg.to_s }\x02"
  end
  
  def rjust msg, justify = 15
    msg.to_s.rjust(justify)
  end
end
