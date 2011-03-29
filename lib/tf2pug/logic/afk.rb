require 'tf2pug/constants'

module AfkLogic
  def self.update_spoken user
    @spoken[user.nick] = Time.now
    
    if @afk.delete user.nick and @afk.empty?
      attempt_delay # logic/state.rb
    end
  end

  def self.check_afk list
    list.select do |nick|
      !@spoken[nick] or (Time.now - @spoken[nick]).to_i > Constants.settings['afk']
    end
  end
  
  def self.start_afk
    state "afk"
  
    @afk = check_afk @signups.keys
    return if @afk.empty?
  
    message "#{ colourize rjust("AFK players:"), :yellow } #{ @afk * ", " }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants.delays['afk'] } seconds to avoid being removed."
    end
    
    sleep Constants.delays['afk']
    
    # return if not needed
    return unless @state == Constants.states['afk']

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |nick| @signups.delete nick }
    @afk.clear

    list_players # logic/players.rb
  end
  
  def self.list_afk
    message "#{ rjust "AFK players:" } #{ check_afk(@signups.keys) * ", " }"
  end
end
