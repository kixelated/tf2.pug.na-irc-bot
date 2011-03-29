require 'tf2pug/constants'
require 'tf2pug/bot/irc'

module AfkLogic
  def self.spoken_player player
    user = User.find_user
    spoken_user user
  end
  
  def self.spoken_user
    user.update(:spoken_at => Time.now)
  end

  def self.check_afk timeout
    MatchLogic::last_pug.signups.group(:user).include(:user).all.select do |signup|
      signup.user.spoken_at + timeout < Time.now
    end
  end
  
  def self.warn_afk
    afk = check_afk(Constants.settings['afk'])
    afk_nicks = afk.collect { |signup| signup.user.nick }
    
    message "#{ colourize rjust("AFK players:"), :yellow } #{ afk_nicks * ", " }"
    afk_nicks.each do |nick|
      Irc::privmsg nick, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants.delays['afk'] } seconds to avoid being removed."
    end
  end
  
  def self.remove_afk
    timeout = Constants.settings['afk'] + Constants.delays['afk']
    
    check_afk(timeout).each do |signup|
      SignupLogic::remove_user signup.user
    end
  end
  
  def self.list_afk
    afk_nicks = check_afk(Constants.settings['afk']).collect { |signup| signup.user.nick }
    message "#{ rjust "AFK players:" } #{ afk_nicks * ", " }"
  end
end
