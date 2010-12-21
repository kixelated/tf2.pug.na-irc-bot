require_relative '../model/user'
require_relative '../util'

module PlayersLogic
  def add_player user, classes
    return notice user, "You cannot add at this time, please wait for picking to end." unless can_add? # logic/state.rb
    return notice user, "You must be registered with GameSurge in order to play in this channel. http://www.gamesurge.net/newuser/" unless user.authed?

    classes.collect! { |clss| clss.downcase }
    rej = classes.reject! { |clss| not const["teams"]["classes"].key? clss }
    classes.uniq!
    
    notice user, "Invalid classes, possible options are #{ const["teams"]["classes"].keys.join(", ") }" if rej
    return if classes.empty?
    
    create_player user unless User.find_by_auth(user.authname)

    @signups[user.nick] = classes
    @auth[user.nick] = u.authname
  end
  
  def create_player user
    notice user, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
    notice user, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."
  
    User.create(:auth => user.authname, :name => user.authname)
  end
  
  def update_player user
    return notice user, "You must be registered with GameSurge in order to play in this channel. http://www.gamesurge.net/newuser/" unless user.authed?
    
    player = User.find_by_auth(user.authname)
    return notice user, "Could not find an account registered to your authname, please !add up at least once." unless player
    return notice user, "Your name has not changed." if player.name == user.nick
 
    message "#{ player.name } is now known as #{ user.nick }"
 
    player.name = user.nick
    player.save
  end
  
  def remove_player nick
    return notice nick, "You cannot remove at this time." unless can_remove? # logic/state.rb

    @signups.delete nick
    @auth.delete nick
  end
  
  def replace_player nick, replacement
    remove_player nick if add_player replacement, @signups[nick] 
  end
  
  def reward_player user
    unless u = find_by_auth(user.authname)
      total = 0
      ratio = calculate_ratios u
      const["reward"]["classes"].each { |clss| total += ratio[clss] }
      
      Channel(const["irc"]["channel"]).voice user if total >= const["reward"]["ratio"]
    end
  end
  
  def get_classes
    @signups.invert_proper_arr
  end
  
  def classes_needed players, multiplier = 1
    required = const["teams"]["classes"].collect_proper { |k, v| v * multiplier - players[k].size }
    required.reject! { |k, v| v <= 0 } # Remove any negative or zero values
    required
  end
  
  def list_players
    output = @signups.collect_proper do |nick, classes|
      medic, captain = classes.include?("medic"), classes.include?("captain")
      special = ":#{ colourize "m", const["colours"]["red"] if medic }#{ colourize "c", const["colours"]["yellow"] if captain }" if medic or captain
      "#{ nick }#{ special }"
    end
    
    message "#{ rjust("#{ @signups.size } users added:") } #{ output.values.join(", ") }"
  end

  def list_players_detailed
    classes = get_classes

    const["teams"]["classes"].each_key do |k|
      message "#{ colourize rjust("#{ k }:"), const["colours"]["lgrey"] } #{ classes[k].join(", ") }" unless classes[k].empty?
    end
  end
  
  def list_players_numbers
    classes = get_classes
    lookup_i = @lookup.invert
    
    const["teams"]["classes"].each_key do |k|
      output = classes[k].collect { |p| "(#{ lookup_i[p] }) #{ p }" }
      message "#{ colourize rjust("#{ k }:"), const["colours"]["lgrey"] } #{ output.join(", ") }" unless classes[k].empty?
    end
  end
 
  def list_classes_needed
    output = classes_needed(get_classes, const["teams"]["count"])
    output["players"] = const["teams"]["total"] - @signups.size if @signups.size < const["teams"]["total"]
    
    o = output.collect { |k, v| "#{ v } #{ k }" } # Format the output

    message "#{ rjust "Required classes:" } #{ o.join(", ") }"
  end
  
  def calculate_ratios player
    total = player.players.count
    
    Hash.new.tap do |ratios|
      player.stats.group("class").each { |stat| ratios[stat.class] = stat.count / total }
      ratios.default = 0
    end
  end

  def list_stats user, nick
    u = User.find_by_name(nick)
    u = User.find_by_auth(nick) unless u
    u = User.find_by_auth(User(nick).authname) unless u or !User(nick)
    
    return notice user, "No user found by that name." unless u
    
    output = calculate_ratios(u).collect { |clss, percent| "#{ (percent * 100).floor }% #{ clss }" }
    
    message "#{ u.name } has #{ u.players.count } games played: #{ output.join(", ") }"
  end

  def minimum_players?
    return false if @signups.size < const["teams"]["total"]
    return classes_needed(get_classes, const["teams"]["count"]).empty?
  end
end
