require 'chronic_duration'

require 'tf2pug/constants'
require 'tf2pug/bot/irc'
require 'tf2pug/model/match'
require 'tf2pug/model/tfclass'
require 'tf2pug/model/user'

module SignupLogic
  def self.add_user(player, classes)
    tfclasses = Tfclass.all(:pug.gte => 1) # select all of the pug-friendly classes
    tfnames = tfclasses.collect { |tf| tf.name }
    
    return Irc.notice user, "No classes entered. Usage: !add #{ tfnames * " " }" unless classes
    
    classes.collect! { |name| name.downcase } # convert classes to lowercase
    classes.uniq! # remove duplicate entries
    
    player.refresh unless player.authed? # refresh and see if recently authed
    Irc.notice player, "You are not authorized with Gamesurge. You can still play in the channel, but any accumulated stats will only be connected to this nick. Please follow this guide to register and authorize with Gamesurge: http://www.gamesurge.net/newuser/" unless user.authed?
    
    user = User.find_player(player) or User.create_user(player) # find or create user
    return Irc.notice player, "You are restricted from playing in this channel." if user.restricted?
    
    total = user.picks.total(:tfclass) # determine total games played
    if classes.include?("captain") and total < Constants.captain['min'] # check captain requirements
      Irc.notice player, "You need #{ total - Constants.captain['min'] } more games before you can add as captain."
      classes.delete("captain")
    end
 
    classes = tfclasses.select { |tf| classes.include?(tf.name) } # keep the classes signed up for 
    return Irc.notice player, "Invalid classes. Possible options are #{ tfnames * ", " }" if classes.empty?
    
    pug = Pug.last # find most recent pug
    return Irc.notice player, "You cannot add at this time." unless pug.can_add?
    
    pug.add(user, classes)
  end
  
  def self.remove_user(player)
    return Irc.notice nick, "You cannot remove at this time." unless match.can_remove?
    
    user = User.find_player(player)
    return Irc.notice player, "Could not find user." unless user
    
    pug = Pug.last
    return Irc.notice player, "You cannot remove at this time." unless pug.can_add?
    
    pug.remove(user)
  end
  
  def self.replace_player(player_old, player_new, admin = nil)
    pug = Pug.last
    return Irc.notice admin, "You cannot add or remove at this time." unless pug.can_remove?
    
    user_old = User.find_player player_old
    return Irc.notice admin, "Cannot find user #{ player_old }." unless user_old
    
    user_new = User.find_player player_new
    return Irc.notice admin, "Cannot find user #{ player_new }." unless user_new
    
    pug.replace(user_old, user_new)
  end
  
  def self.list_signups
    pug = Pug.last
    
    # TODO: I'm just making this query up; it needs to be verified
    user_signups = pug.signups.group(:user).include(:tfclass).collect do |user_signup|
      user_classes = user_signup.tfclass.each do |user_class|
        colourize user_class.name[0], user_class.name.to_sym # color the first letter of each class
      end
      "#{ user_signup.user.name }:#{ user_classes * "" }"
    end
    
    Irc.message "#{ rjust("#{ user_signups.size } users added:") } #{ user_signups * ", " }"
  end
  
  def self.list_signups_delay
    list_signups unless @show_list > 0
    @show_list += 1
  end
  
  # TODO: Find a place to put this
  def self.classes_needed(pug)
    req = Tfclass.all(:pug.gte => 1).collect { |tf| [ tf, tf.pug * 2 - pug.signups.count(:tfclass => tf) ] }
    req.select! { |tf, count| count > 0 }
    Hash[req]
  end
  
  def self.list_classes_needed
    pug = Pug.last
    return unless pug.can_add? or pug.can_remove?
    
    output = classes_needed(pug).collect { |tf, count| "#{ count } #{ tf.name }" }
    
    player_req = (Tfclass.sum(:pug) - 1) * 2 - match.signups.count(:user)
    output << "#{ player_req } players" if player_req > 0
  
    Irc.message "Classes needed: #{ output * ", " }"
  end
end
