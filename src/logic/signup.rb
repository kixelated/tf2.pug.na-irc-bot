require 'chronic_duration'

require_relative '../bot/irc'
require_relative '../logic/match'
require_relative '../logic/state'
require_relative '../model/tfclass'
require_relative '../model/user'

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
    Irc::notice player, "You cannot add at this time, but you have been added to the next pug." unless StateLogic::can_add?
    
    match = MatchLogic::last_pug # find most recent pug
    add_user match, user, classes # add the user to the pug
  end
  
  def self.add_user match, user, classes
    remove_user match, user # remove in case already signed up
    classes.each { |clss| match.signups.create(:user => user, :class => clss) } # create the signup
  end
  
  def self.remove_player player
    return notice nick, "You cannot remove at this time." unless StateLogic::can_remove?
    
    user = UserLogic::find_user(player)
    match = MatchLogic::last_pug
    
    remove_user match, user # remove the user
  end
  
  def self.remove_user match, user
    match.signups.delete(:user => user) # delete any signups
  end
  
  def self.replace_player player, player_replacement
    # TODO
  end
 
  def self.replace_user match, user, user_replacement
    # TODO
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
 
  def self.list_classes_needed
    # TODO
  end

  def self.minimum_players? players = @signups
    # TODO
  end
end
