require_relative '../bot/irc'
require_relative '../model/user'

module UserLogic
  def find_user player
    user = User.first(:auth => player.authname) if player.authed? # select by auth
    
    unless user
      user = User.first(:nick => player.nick, :auth => nil) # select by nick
      user.update(:auth => player.authname) if user and player.authed? # update user if recently authed
    end
    
    return user
  end
  
  def create_user player
    Irc::notice player, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
    Irc::notice player, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."

    User.create(:auth => player.authname, :nick => player.nick)
  end
  
  def restrict_player admin, player, duration
    user = find_user(player)
    duration = ChronicDuration.parse(duration)
    
    return Irc::notice admin, "Could not find user." unless user
    return Irc::notice admin, "Unknown duration." unless duration
    
    restrict_user user, duration
  end
  
  def restrict_user user, duration
    message "#{ user.nick } has been restricted for #{ ChronicDuration.output(duration) }."
    
    remove_user user
    user.update(:restricted_at => Time.now.to_i + duration)
  end
  
  def authorize_player admin, player
    user = find_user player
    
    return Irc::notice user, "Could not find user." unless user
    return Irc::notice user, "User is not restricted." unless user.restricted_at
    
    authorize_user user
  end
  
  def authorize_user user, nick
    message "#{ user.nick } is no longer restricted."
    
    user.update(:restricted_at => 0)  
  end
  
  def update_restrictions 
    User.all(:restricted_at.gte => Time.now).each { |user| authorize_user user }
  end

  def nick_player player, nick
    player.refresh unless player.authed? # refresh in case recently authed
    return Irc::notice player, "You must be registered with GameSurge in order to change your nick. http://www.gamesurge.net/newuser/" unless player.authed?
    
    user = find_user player
    return Irc::notice player, "Could not find an account registered to your authname." unless user.auth
    return Irc::notice player, "Your nick has not changed." if user.nick == nick
    
    Irc::message "#{ user.nick } is now known as #{ nick }"
    nick_user user, nick
  end
  
  def nick_user user, nick
    user.update(:nick => nick)
  end
  
  def reward_player player
    user = find_user player
    reward = reward_user user
    
    return Irc::notice player, "You need #{ Constants.reward['min'] } games and #{ (Constants.reward['ratio'] * 100).round }% on #{ Constants.reward['classes'] * " + " } to get voice" unless reward
    
    Channel(Constants.irc['channel']).voice(player)
  end
  
  def reward_user user
    total = StatsLogic::calculate_total(user)
    return if total < Constants.reward['min']
    
    ratio = StatsLogic::calculate_ratios(user, total)
    sum = Constants.reward['classes'].inject(0.0) { |sum, name| sum + ratio[name] }
    return if sum < Constants.reward['ratio']
    
    return true
  end
end
