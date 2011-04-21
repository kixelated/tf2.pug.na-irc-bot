require 'singleton'

require 'tf2pug/bot/irc'
require 'tf2pug/model/user'

class UserCache
  include Singleton

  def initialize 
    @cache = {}
  end
  
  def create(player)
    @cache[player] = User.first_or_create(:auth => player.authname, :nick => player.nick)
  end
  
  def find(player)
    return @cache[player] if @cache.key?(player)
    
    if player.authed?
      user = User.first(:auth => player.authname) # select by auth
      user = User.first(:nick => player.nick, :auth => nil) unless user # select by nick if fails
      user.update(:nick => player.nick, :auth => player.authname) if user # update nick and auth
    else
      user = User.first(:nick => player.nick, :auth => nil) # select by nick
    end
    
    @cache[player] = user
  end
  
  def update(player, replacement)
    @cache[replacement] = @cache.delete(player)
  end
end

module UserLogic
  def self.create_player player
    if UserCache.instance.create player
      Irc.notice player, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
      Irc.notice player, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."
    end
  end

  def self.find_player player
    UserCache.instance.find(player)
  end

  def self.restrict_user(player, duration, admin = nil)
    return Irc.notice admin, "Could not find user." unless user
    
    begin
      duration = ChronicDuration.parse(duration)
      
      user.restrict duration
      Irc.message "#{ player } has been restricted for #{ ChronicDuration.output(duration) }."
      
      remove_user user
    catch Exception => e
      Irc.notice admin, e.Irc.message
    end
  end
  
  def self.authorize_user(admin, player)
    user = find_user player
    
    return Irc.notice user, "Could not find user." unless user
    return Irc.notice user, "User is not restricted." unless user.restricted?
    
    user.authorize
    
    Irc.notice user, "#{ player } is no longer restricted."
  end
  
  def self.update_restrictions 
    User.all(:restricted_at.gte => Time.now).each do |user| 
      user.authorize
      Irc.notice user, "#{ player } is no longer restricted."
    end
  end
  
  def self.reward_player(player)
    user = find_player player
    
    total = StatsLogic::calculate_total(user)
    return if total < Constants.reward['min']
    
    ratio = StatsLogic::calculate_ratios(user, total)
    sum = Constants.reward['classes'].inject(0.0) { |sum, name| sum + ratio[name] }
    return if sum < Constants.reward['ratio']
   
    Channel(Constants.irc['channel']).voice(player)
  end
end
