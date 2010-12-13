module PlayersLogic
  def add_player user, classes
    return notice user, "You cannot add at this time, please wait for picking to end." unless can_add? # stateLogic.rb
    notice user, "You must be registered with GameSurge in order to play in this channel, but consider this a warning. http://www.gamesurge.net/newuser/" unless User(user).authed?
    
    classes.collect! { |clss| clss.downcase }
    classes.reject! { |clss| not const["teams"]["classes"].key? clss }

    return notice user, "Invalid classes, you have not been added." if classes.empty?

    @players[user] = classes
  end

  def remove_player user
    return notice user, "You cannot remove at this time." unless can_remove? # stateLogic.rb

    @players.delete user
  end
  
  def list_players
    output = @players.collect do |user, classes|
      medic, captain = classes.include?("medic"), classes.include?("captain")
      special = ":#{ colourize "m", const["colours"]["red"] if medic }#{ colourize "c", const["colours"]["yellow"] if captain }" if medic or captain
      "#{ user }#{ special }"
    end
    
    message "#{ rjust("#{ @players.size } users added:") } #{ output.values.join(", ") }"
  end

  def list_players_detailed
    temp = get_classes
    const["teams"]["classes"].each_key do |k|
      message "#{ colourize rjust("#{ k }:"), const["colours"]["lightgrey"] } #{ temp[k].join(", ") }" if temp[k]
    end
  end
  
  def replace_player user, replacement
    if @players.key? user
      return @players[replacement] = @players.delete(user)
    else
      @teams.each do |team|
        if team.players.key? user
          team.captain = replacement if team.captain == user
          return team.players[replacement] = team.players.delete(user) 
        end
      end
    end
    false
  end
  
  def get_classes
    @players.invert_proper_arr
  end
  
  # I hate this function, but it is so important
  def classes_needed players, multiplier = 1
    required = const["teams"]["classes"].collect { |k, v| v * multiplier - players[k].size }
    required.reject! { |k, v| v <= 0 } # Remove any negative or zero values
    required
  end

  def list_classes_needed
    output = classes_needed(get_classes, const["teams"]["count"]).to_a
    output.unshift [ "players" , (const["teams"]["size"] * const["teams"]["count"] - @players.size)] if @players.size < const["teams"]["size"] * const["teams"]["count"]
    output.collect! { |a| "#{ a[1] } #{ a[0] }" } # Format the output

    message "#{ rjust "Required classes:" } #{ output.join(", ") }"
  end

  def minimum_players?
    return false if @players.size < const["teams"]["size"] * const["teams"]["count"]
    return classes_needed(get_classes, const["teams"]["count"]).empty?
  end
end