require 'chronic_duration'

require 'tf2pug/bot/irc'
require 'tf2pug/logic/match'
require 'tf2pug/logic/stats'
require 'tf2pug/logic/user'
require 'tf2pug/model/tfclass'
require 'tf2pug/model/user'

module SignupLogic 
  def self.add_player player, classes
    tfclasses = Tfclass.all(:pug.gte => 1) # select all of the pug-friendly classes
    tfnames = tfclasses.collect { |tf| tf.name }
    
    return Irc::notice user, "No classes entered. Usage: !add #{ tfnames * " " }" unless classes
    
    classes.collect! { |name| name.downcase } # convert classes to lowercase
    classes.uniq! # remove duplicate entries
    
    player.refresh unless player.authed? # refresh and see if recently authed
    Irc::notice player, "You are not authorized with Gamesurge. You can still play in the channel, but any accumulated stats will only be connected to this nick. Please follow this guide to register and authorize with Gamesurge: http://www.gamesurge.net/newuser/" unless user.authed?
    
    user = UserLogic::find_user(player) or UserLogic::create_user(player) # find or create user
    total = StatsLogic::calculate_total(user) # determine total games played
    
    if classes.include?("captain") and total < Constants.captain['min'] # check captain requirements
      Irc::notice player, "You must have #{ Constants.captain['min'] } games played to add as captain."
      classes.delete("captain")
    end
 
    classes = tfclasses.select { |tf| classes.include?(tf.name) } # keep the classes signed up for 
    return Irc::notice player, "Invalid classes. Possible options are #{ tfnames * ", " }" if classes.empty?
    return Irc::notice player, "You are restricted from playing in this channel." if user.restricted_at
    return Irc::notice player, "You cannot add at this time." unless MatchLogic::can_add?
    
    match = MatchLogic::last_pug # find most recent pug
    add_user match, user, classes # add the user to the pug
  end
  
  def self.add_user match, user, classes
    remove_user match, user # remove in case already signed up
    classes.each { |clss| match.signups.create(:user => user, :class => clss) } # create the signup
  end
  
  def self.remove_player player
    return Irc::notice nick, "You cannot remove at this time." unless MatchLogic::can_remove?
    
    user = UserLogic::find_user(player)
    match = MatchLogic::last_pug
    
    remove_user match, user # remove the user
  end
  
  def self.remove_user match, user
    match.signups.delete(:user => user) # delete any signups
  end
  
  def self.replace_player player_old, player_new
    match = MatchLogic::last_pug
    user_old = UserLogic::find_user player_old
    user_new = UserLogic::find_user player_new
    
    # TODO Messages for admins
    return unless user_old and user_new
    
    replace_user match, user_old, user_new
  end
 
  def self.replace_user match, user_old, user_replacement
    match.signups.all(:user => user_old).update(:user => user_replacement)
    match.matchups.picks.all(:user => user_old).update(:user => user_replacement) # TODO: Probably won't work
  end
  
  def self.list_signups
    match = MatchLogic::last_pug
    
    # TODO: I'm just making this query up, needs to be verified
    user_signups = match.signups.group(:user).include(:tfclass).collect do |user_signup|
      user_classes = user_signup.tfclass.each do |user_class|
        colourize user_class.name[0], user_class.name.to_sym # color the first letter of each class
      end
      "#{ user_signup.user.name }:#{ user_classes * "" }"
    end
    
    Irc::message "#{ rjust("#{ user_signups.size } users added:") } #{ user_signups * ", " }"
  end
  
  def self.list_signups_delay
    list_signups unless @show_list > 0
    @show_list += 1
  end
  
  def self.classes_needed
    match = MatchLogic::last_pug
    
    req = Tfclass.all(:pug.gte => 1).collect { |tf| [ tf, tf.pug * 2 - match.signups.count(:tfclass => tf) ] }
    req.select! { |tf, count| count > 0 }
    Hash[req]
  end
 
  def self.list_classes_needed
    output = classes_needed.collect { |tf, count| "#{ count } #{ tf.name }" }
    
    player_req = (Tfclass.sum(:pug) - 1) * 2 - match.signups.count(:user)
    output << "#{ player_req } players" if player_req > 0
  
    Irc::message "Classes needed: #{ output * ", " }"
  end
end
