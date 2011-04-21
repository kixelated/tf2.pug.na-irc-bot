require 'chronic_duration'

require 'tf2pug/constants'
require 'tf2pug/bot/irc'
require 'tf2pug/logic/pug'
require 'tf2pug/logic/user'
require 'tf2pug/model/match'
require 'tf2pug/model/tfclass'
require 'tf2pug/model/user'

module SignupLogic
  def self.add_signup(player, classes)
    tfclasses = Tfclass.pug # select all of the pug-friendly classes
    tfnames = tfclasses.collect { |tf| tf.name }
    
    return Irc.notice user, "No classes entered. Usage: !add #{ tfnames * " " }" unless classes
    
    classes.collect! { |name| name.downcase } # convert classes to lowercase
    classes.uniq! # remove duplicate entries
    
    player.refresh unless player.authed? # refresh and see if recently authed
    Irc.notice player, "You are not authorized with Gamesurge. You can still play in the channel, but any accumulated stats will only be connected to this nick. Please follow this guide to register and authorize with Gamesurge: http://www.gamesurge.net/newuser/" unless player.authed?
    
    user = UserLogic.find_player(player) || UserLogic.create_player(player) # find or create user
    return Irc.notice player, "You are restricted from playing in this channel." if user.restricted?
    
    total = user.picks.count # determine total pugs played
    if classes.include?("captain") and total < Constants.settings['captain_min'] # check captain requirements
      Irc.notice player, "You need #{ Constants.settings['captain_min'] - total } more games before you can add as captain."
      classes.delete("captain")
    end
 
    classes = tfclasses.select { |tf| classes.include?(tf.name) } # keep the classes signed up for 
    return Irc.notice player, "Invalid classes. Possible options are #{ tfnames * ", " }" if classes.empty?
    
    Irc.notice player, "You cannot add at this time, and have been added to the next pug." if Pug.picking

    pug = Pug.waiting || PugLogic.create_pug
    pug.add_signup(user, classes)
  end

  def self.remove_signup(player)
    user = UserLogic.find_player(player)
    return Irc.notice player, "Could not find user." unless user
    
    unless Pug.waiting.remove_signup(user)
      # maybe they were trying to remove during picking
      Irc.notice player, "You cannot remove at this time." if Pug.picking and Pug.picking.signups.first(:user => user)
    end
  end

  def self.replace_signup(player_old, player_new, admin = nil)
    user_old = UserLogic.find_player player_old
    user_new = UserLogic.find_player player_new
    
    return Irc.notice admin, "Cannot find user #{ player_old }." unless user_old
    return Irc.notice admin, "Cannot find user #{ player_new }." unless user_new
  
    Pug.waiting.replace_signup(user_old, user_new)
  end

  def self.list_signups
    pug = Pug.waiting
    
    signups = { }
    pug.signups.all.each do |signup|
      signups[signup.user] ||= []
      signups[signup.user] << signup.tfclass
    end
    
    output = signups.collect do |user, tfclasses|
      temp = tfclasses.collect do |tfclass|
         # color the first letter of each class if medic or captain
        Irc.colourize tfclass.name[0], tfclass.name.to_sym if tfclass.name == "medic" or tfclass.name == "captain"
      end
      "#{ user.nick }#{ ":#{ temp * "" }" unless temp.compact.empty? }"
    end
    
    Irc.message "#{ Irc.rjust("#{ output.size } users added:") } #{ output * ", " }"
  end

  # TODO: Find a place to put this
  def self.classes_needed(pug)
    tfclasses = Tfclass.all(:pug.gte => 1).collect { |tfclass| [tfclass, tfclass.pug * 2] }
    tfclasses = Hash[tfclasses]
  
    pug.signups.all.each { |signup| tfclasses[signup.tfclass] -= 1 }
    tfclasses.select { |tf, count| count > 0 }
  end

  def self.players_needed(pug)
    required = (Tfclass.all.sum(:pug) - 1) * 2 # - 1 to factor in captain, * 2 for number of teams
    avaliable = pug.signups.all(:fields => [:user_id], :unique => true).size
    
    required - avaliable
  end

  def self.list_classes_needed
    pug = Pug.last
    
    needed = players_needed(pug)
    output = classes_needed(pug).collect { |tf, count| "#{ count } #{ tf.name }" }
    output << "#{ needed } players" if needed > 0

    Irc.message "Classes needed: #{ output * ", " }"
  end
end
