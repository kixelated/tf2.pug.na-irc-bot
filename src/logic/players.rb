require 'chronic_duration'

require_relative '../model/user'
require_relative '../util'

module PlayersLogic
  def add_player user, classes
    return notice user, "Invalid classes, possible options are #{ const["teams"]["classes"].keys * ", " }" unless classes
        
    user.refresh unless user.authed?
    notice user, "You are not authorized with Gamesurge. You can still play in the channel, but any accumulated stats may be lost and will not transfer if you change your nick. Please follow this guide to register and authorize with Gamesurge: http://www.gamesurge.net/newuser/" unless user.authed?
    
    # clean up the classes, removing any invalid or duplicate items
    classes.collect! { |clss| clss.downcase }
    classes.reject! { |clss| not const["teams"]["classes"].key? clss }
    classes.uniq!
    
    return notice user, "Invalid classes, possible options are #{ const["teams"]["classes"].keys * ", " }" if classes.empty?
  
    user.refresh unless user.authed?
    
    u = find_user user
    u = create_user user unless u
  
    return notice user, "You are restricted from playing in this channel." if u.restriction
    
    # add the player to the pug
    if can_add?
      @signups[user.nick] = classes
      @auth[user.nick] = u
    else
      @toadd[user.nick] = classes
      notice user, "You cannot add at this time, but you will be added once the picking process is over."
    end
  end
  
  def find_user user
    u = User.find_by_auth(user.authname) if user.authed?
    u = User.where("name = ? AND auth != NULL", user.nick).first unless u # give priority to authed accounts
    u = User.find_by_name(user.nick) unless u
    
    return u
  end
  
  def create_user user
    notice user, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
    notice user, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."

    User.create(:auth => user.authname, :name => user.nick)
  end

  def update_player user, nick
    user.refresh unless user.authed?
    return notice user, "You must be registered with GameSurge in order to change your nick. http://www.gamesurge.net/newuser/" unless user.authed?
    
    player = User.find_by_auth(user.authname)
    return notice user, "Could not find an account registered to your authname, please !add up at least once." unless player
    return notice user, "Your name has not changed." if player.name == nick
 
    message "#{ player.name } is now known as #{ nick }"
    
    player.update_attributes(:name => nick)
    @auth[user.nick] = player if @auth[user.nick]
  end
  
  def remove_player nick
    unless can_remove?
      @toremove << nick if @signups.key? nick
      return notice nick, "You cannot remove at this time, but captains will be informed not to pick you."
    end

    @signups.delete nick
    @auth.delete nick
  end
  
  def replace_player nick, replacement
    remove_player nick if add_player replacement, @signups[nick] 
  end
  
  def reward_player user
    u = find_user user

    return unless u
     
    sum = 0.0
    total = u.players.count
    
    return if total < const["reward"]["min"].to_i
    
    ratio = calculate_ratios u
    const["reward"]["classes"].each { |clss| sum += ratio[clss] }
    
    return if sum < const["reward"]["ratio"].to_f
    
    Channel(const["irc"]["channel"]).voice user
    return true
  end
  
  def explain_reward user
    notice user, "You need #{ const["reward"]["min"] } games and #{ (const["reward"]["ratio"].to_f * 100).round }% on #{ const["reward"]["classes"] * " + " } to get voice."
  end
  
  def restrict_player user, nick, duration
    u = find_user User(nick)
    duration = ChronicDuration.parse(duration)
    
    return notice user, "Could not find user." unless u
    return notice user, "Unknown duration." unless duration
    
    remove_player nick
    u.restriction = Restriction.create(:time => (Time.now.to_i + duration))
    
    message "#{ u.name } has been restricted for #{ ChronicDuration.output(duration, :format => :long) }."
  end
  
  def authorize_player user, nick
    u = find_user User(nick)
    
    return notice user, "Could not find user." unless u
    return notice user, "User is not restricted." unless u.restriction
    
    u.restriction.delete
    message "#{ u.name } is no longer restricted."
  end
  
  def update_restrictions 
    Restriction.includes("user").where("time < ?", Time.now.to_i).each do |r|
      message "#{ r.user.name } is no longer restricted."
      r.delete
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
    
    message "#{ rjust("#{ @signups.size } users added:") } #{ output.values * ", " }"
  end

  def list_players_detailed
    classes = get_classes

    const["teams"]["classes"].each_key do |k|
      message "#{ colourize rjust("#{ k }:"), const["colours"]["lgrey"] } #{ classes[k] * ", " }" unless classes[k].empty?
    end
  end
 
  def list_classes_needed
    output = classes_needed(get_classes, const["teams"]["count"])
    output["players"] = const["teams"]["total"] - @signups.size if @signups.size < const["teams"]["total"]
    
    o = output.collect { |k, v| "#{ v } #{ k }" } # Format the output

    message "#{ rjust "Required classes:" } #{ o * ", " }"
  end
  
  def calculate_ratios user
    total = user.players.count
    classes = user.stats.group("tfclass_id").count
    # TODO: .include("tf2class")

    Hash.new.tap do |ratios|
      classes.each do |clss, count|
        temp = Tfclass.find(clss).name
        ratios[temp] = count.to_f / total.to_f
      end
      ratios.default = 0
    end
  end

  def list_stats user
    u = find_user user

    return message "There are no records of the user #{ user.nick }" unless u
    
    total = u.players.count
    output = calculate_ratios(u).collect { |clss, percent| "#{ (percent * 100).round }% #{ clss }" }

    message "#{ u.name }#{ "*" unless u.auth } has #{ u.players.count } games played: #{ output * ", " }"
  end

  def minimum_players?
    return false if @signups.size < const["teams"]["total"]
    return classes_needed(get_classes, const["teams"]["count"]).empty?
  end
end