require 'chronic_duration'

require_relative '../model/user'
require_relative '../util'

module PlayersLogic
  def add_player user, classes
    return notice user, "No classes entered. Usage: !add #{ const["teams"]["classes"].keys * " " }" unless classes
         
    user.refresh unless user.authed?
    notice user, "You are not authorized with Gamesurge. You can still play in the channel, but any accumulated stats may be lost and will not transfer if you change your nick. Please follow this guide to register and authorize with Gamesurge: http://www.gamesurge.net/newuser/" unless user.authed?
    
    classes.collect! { |clss| clss.downcase } # convert classes to lowercase
    classes.uniq! # remove duplicate classes
    
    rej = classes.reject! { |clss| not const["teams"]["classes"].key? clss } # remove invalid classes
    notice user, "Invalid classes. Possible options are #{ const["teams"]["classes"].keys * ", " }" if rej

    u = find_user user
    u = create_user user unless u
    update_user user, u if user.authed? and not u.auth 
   
    total = calculate_total u
    cap = classes.delete("captain") if total < const["captain"]["min"]
    
    return notice user, "You are restricted from playing in this channel." if u.restriction
    notice user, "You must have #{ const["captain"]["min"] } games played to add as captain." if cap
    
    return if classes.empty?
    
    # add the player to the pug
    if can_add?
      @signups[user.nick] = classes
      @auth[user.nick] = u
    elsif not @signups.key?(user.nick)
      @toadd[user.nick] = classes
      notice user, "You cannot add at this time, but you will be added once the picking process is over."
    end
  end
  
  def add_player! user, classes
    return if classes.empty?
  
    u = find_user user
    u = create_user user unless u
    update_user user, u if user.authed? and not u.auth 
    
    @signups[user.nick] = classes
    @signups_all = classes if state? "picking"
    @auth[user.nick] = u
  end
  
  def find_user user
    u = User.find_by_auth(user.authname) if user.authed?
    u = User.where("name = ? AND auth != NULL", user.nick).first unless u # give priority to authed accounts
    u = User.find_by_name(user.nick) unless u
    
    return u
  end
  
  def update_user user, u
    u.update_attributes(:auth => user.authname)
  end
  
  def create_user user
    notice user, "Welcome to #tf2.pug.na! The channel has certain quality standards, and we ask that you have a good amount of experience and understanding of the 6v6 format before playing here. If you do not yet meet these requirements, please type !remove and try another system like tf2lobby.com"
    notice user, "If you are still interested in playing here, there are a few rules that you can find on our wiki page. Please ask questions and use the !man command to list all of the avaliable commands. Teams will be drafted by captains when there are enough players added, so hang tight and don't fret if you are not picked."

    User.create(:auth => user.authname, :name => user.nick)
  end

  def update_nick user, nick
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
    return unless @signups.key? nick # player is not signed up or was picked already
    
    classes = remove_player! nick
    unless can_remove? or minimum_players?(@signups_all)
      add_player! User(nick), classes # player is required and cannot remove
      
      @toremove << nick if @signups.key? nick
      return notice nick, "You cannot remove at this time, but will be removed after picking is over."
    end
    
    true
  end
  
  def remove_player! nick
    @auth.delete nick
    @signups_all.delete nick
    @signups.delete nick
  end
  
  def replace_player! nick, replacement
    classes = remove_player! nick
    return add_player! replacement, classes if classes
    
    if state? "picking" and @signups_all.key? nick
      @signups_all[replacement.nick] = @signups_all.delete(nick)
      
      @teams.each do |team|
        if team.signups.key? nick
          team.signups[replacement.nick] = team.signups.delete(nick)
          if team.captain == nick
            team.captain = replacement.nick
            
            list_captain nil
            tell_captain if replacement.nick == current_captain
          end
        end
      end
    end
  end
  
  def reward_player user
    u = find_user user
    return unless u
     
    total = calculate_total u
    return if total < const["reward"]["min"]
    
    ratio = calculate_ratios u
    sum = const["reward"]["classes"].inject(0.0) { |sum, clss| sum + ratio[clss] }
    return if sum < const["reward"]["ratio"]
    
    Channel(const["irc"]["channel"]).voice user
    return true
  end
  
  def explain_reward user
    notice user, "You need #{ const["reward"]["min"] } games and #{ (const["reward"]["ratio"] * 100).round }% on #{ const["reward"]["classes"] * " + " } to get voice."
  end
  
  def restrict_player user, nick, duration
    u = find_user User(nick)
    duration = ChronicDuration.parse(duration)
    
    return notice user, "Could not find user." unless u
    return notice user, "Unknown duration." unless duration
    remove_player nick
    
    u.restriction.delete if u.restriction
    u.restriction = Restriction.create(:time => (Time.now.to_i + duration))
    
    message "#{ u.name } has been restricted for #{ ChronicDuration.output(duration) }."
  end
  
  def authorize_player user, nick
    u = find_user User(nick)
    
    return notice user, "Could not find user." unless u
    return notice user, "User is not restricted." unless u.restriction
    
    u.restriction.delete
    message "#{ u.name } is no longer restricted."
  end
  
  def update_restrictions 
    Restriction.includes(:user).where("time < ?", Time.now.to_i).each do |r|
      message "#{ r.user.name } is no longer restricted."
      r.delete
    end
  end
  
  def get_classes
    @signups.invert_proper_arr
  end
  
  def classes_needed(players, multiplier = const["teams"]["count"], requirements = const["teams"]["classes"])
    requirements.inject({}) do |required, (clss, count)|
      temp = count * multiplier - players[clss].size
      required[clss] = temp if temp > 0
      required
    end
  end
  
  def list_players
    output = @signups.collect_proper do |nick, classes|
      medic, captain = classes.include?("medic"), classes.include?("captain")
      special = ":#{ colourize "m", const["colours"]["red"] if medic }#{ colourize "c", const["colours"]["yellow"] if captain }" if medic or captain
      "#{ nick }#{ special }"
    end
    
    message "#{ rjust("#{ @signups.size } users added:") } #{ output.values * ", " }"
  end
  
  def list_players_delay
    list_players unless @show_list > 0
    @show_list += 1
  end

  def list_players_detailed
    classes = get_classes

    const["teams"]["classes"].each_key do |k|
      message "#{ colourize rjust("#{ k }:"), const["colours"]["lgrey"] } #{ classes[k] * ", " }" unless classes[k].empty?
    end
  end
 
  def list_classes_needed
    output = classes_needed(get_classes)
    output["player"] = const["teams"]["total"] - @signups.size if @signups.size < const["teams"]["total"]
    output.collect_proper! { |k, v| "#{ v } #{ k }" } # Format the output

    message "#{ rjust "Required classes:" } #{ output.values * ", " }"
  end
  
  def calculate_total user
    user.players.count(:team_id)
  end
  
  def calculate_ratios user
    total = calculate_total user
    classes = user.picks.group(:tfclass).count

    Hash.new.tap do |ratios|
      classes.each { |tfclass, count| ratios[tfclass.name] = count.to_f / total.to_f }
      ratios.default = 0
    end
  end

  def list_stats user
    u = find_user user
    return message "There are no records of the user #{ user.nick }" unless u
    
    total = calculate_total u
    output = calculate_ratios(u).collect { |clss, percent| "#{ (percent * 100).round }% #{ clss }" }

    message "#{ u.name }#{ "*" unless u.auth } has #{ total } games played: #{ output * ", " }"
  end

  def minimum_players? players = @signups
    return false if players.size < const["teams"]["total"]
    return classes_needed(players.invert_proper_arr).empty?
  end
end
