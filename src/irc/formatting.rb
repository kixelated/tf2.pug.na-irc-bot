module Formatting
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

  def rjust msg, justify = 15
    msg.to_s.rjust(justify)
  end

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
 
  def team_colourize msg, i, back = :black
    colourize msg, Constants.teams']['details'][i]['colour, back
  end
  
  def bold msg
    "\x02#{ msg.to_s }\x02"
  end
end
