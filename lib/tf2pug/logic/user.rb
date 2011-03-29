require 'tf2pug/bot/irc'
require 'tf2pug/model/user'

module UserLogic
  self.cache = {}

  def self.find_user player
    return cache[player] if cache.key? player
    
    user = User.first(:auth => player.authname) if player.authed? # select by auth
    
    if user
      user.update(:nick => player.nick) if user.nick != player.nick # update user's nick
    else
      user = User.first(:nick => player.nick, :auth => nil) # select by nick
      user.update(:auth => player.authname) if user and player.authed? # update user's auth
    end
    
    cache[player] = user
    return user
  end
  
  def self.create_user player
    Irc::notice player, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
    Irc::notice player, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."

    cache[player] = User.create(:auth => player.authname, :nick => player.nick)
  end
  
  def self.rename_player player_old, player_new
    cache[player_new] = cache.delete(player_old) 
  end
  
  def self.restrict_player admin, player, duration
    user = find_user(player)
    duration = ChronicDuration.parse(duration)
    
    return Irc::notice admin, "Could not find user." unless user
    return Irc::notice admin, "Unknown duration." unless duration
    
    restrict_user user, duration
  end
  
  def self.restrict_user user, duration
    message "#{ user.nick } has been restricted for #{ ChronicDuration.output(duration) }."
    
    remove_user user
    user.update(:restricted_at => Time.now.to_i + duration)
  end
  
  def self.authorize_player admin, player
    user = find_user player
    
    return Irc::notice user, "Could not find user." unless user
    return Irc::notice user, "User is not restricted." unless user.restricted_at
    
    authorize_user user
  end
  
  def self.authorize_user user, nick
    message "#{ user.nick } is no longer restricted."
    
    user.update(:restricted_at => 0)  
  end
  
  def self.update_restrictions 
    User.all(:restricted_at.gte => Time.now).each { |user| authorize_user user }
  end
  
  def self.reward_player player
    user = find_user player
    reward = reward_user user
    
    return Irc::notice player, "You need #{ Constants.reward['min'] } games and #{ (Constants.reward['ratio'] * 100).round }% on #{ Constants.reward['classes'] * " + " } to get voice" unless reward
    
    Channel(Constants.irc['channel']).voice(player)
  end
  
  def self.reward_user user
    total = StatsLogic::calculate_total(user)
    return if total < Constants.reward['min']
    
    ratio = StatsLogic::calculate_ratios(user, total)
    sum = Constants.reward['classes'].inject(0.0) { |sum, name| sum + ratio[name] }
    return if sum < Constants.reward['ratio']
    
    return true
  end
end
