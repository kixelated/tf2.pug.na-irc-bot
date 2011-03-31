require 'tf2pug/constants'
require 'tf2pug/model/match'
require 'tf2pug/model/user'

module AfkLogic
  def spoken_player player
    User.find_player(player).update(:spoken_at => Time.now)
  end

  def check_afk timeout = Constants.settings['afk']
    Match.last_pug.signups.group(:user).include(:user).all.select do |signup|
      signup.user.spoken_at + timeout < Time.now
    end
  end
  
  def warn_afk
    afk = check_afk
    afk_nicks = afk.collect { |signup| signup.user.nick }
    
    message "#{ colourize rjust("AFK players:"), :yellow } #{ afk_nicks * ", " }"
    afk_nicks.each do |nick|
      message nick, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants.delays['afk'] } seconds to avoid being removed."
    end
  end
  
  def remove_afk
    match = Match.last_pug
    check_afk(Constants.settings['afk'] + Constants.delays['afk']).each do |signup|
      match.signups.all(:user => user).destroy
    end
  end
  
  def list_afk
    afk_nicks = check_afk.collect { |signup| signup.user.nick }
    message "#{ rjust "AFK players:" } #{ afk_nicks * ", " }"
  end
end
