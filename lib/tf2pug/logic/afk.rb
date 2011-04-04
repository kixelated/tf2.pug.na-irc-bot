require 'tf2pug/constants'
require 'tf2pug/bot/irc'
require 'tf2pug/model/pug'
require 'tf2pug/model/user'

module AfkLogic
  def self.spoken_player player
    User.find_player(player).update(:spoken_at => Time.now)
  end

  def self.check_afk(timeout = Constants.settings['afk'])
    Pug.last.signups.group(:user).include(:user).all.select do |signup|
      signup.user.spoken_at + timeout < Time.now
    end
  end
  
  def self.warn_afk
    afk = check_afk
    afk_nicks = afk.collect { |signup| signup.user.nick }
    
    Irc.message "#{ colourize rjust("AFK players:"), :yellow } #{ afk_nicks * ", " }"
    afk_nicks.each do |nick|
      Irc.message nick, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants.delays['afk'] } seconds to avoid being removed."
    end
  end
  
  def self.remove_afk
    pug = Pug.last
    check_afk(Constants.settings['afk'] + Constants.delays['afk']).each do |signup|
      match.remove(user)
    end
  end
  
  def self.list_afk
    afk_nicks = check_afk.collect { |signup| signup.user.nick }
    Irc.message "#{ rjust "AFK players:" } #{ afk_nicks * ", " }"
  end
end
