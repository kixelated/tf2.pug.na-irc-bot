module PlayersLogic
  def add_player user, classes
    return notice user, "You cannot add at this time, please wait for picking to end." unless can_add?
    return notice user, "You must be authorized with GameSurge in order to play in this channel. http://www.gamesurge.net/newuser/" unless user.authed?
    
    classes.collect! { |clss| clss.downcase }
    classes.reject! { |clss| not Team::Minimum.key? clss }
  
    return notice user, "Invalid classes, you have not been added." if classes.empty?
    
    @players[user] = classes
  end

  def remove_player user
    return notice user, "You cannot remove at this time." unless can_remove?
    
    @players.delete user
  end
  
  def list_players
    message "#{ make_title "#{ @players.size } users added:" } #{ @players.keys.join(", ") }"
  end

  def list_players_detailed
    get_classes.each do |k, v|
      message "#{ make_title "#{ k }:", 2 } #{ v.join(", ") }"
    end
  end
  
  def get_classes
    @players.invert_proper_arr
  end
  
  # I hate this function, but it is so important
  def classes_needed players, multiplier = 1
    # Team::Minimum = { scout => 4, soldier => 4 }
    # required = [[scout, 4], [soldier, 4]]
    required = Team::Minimum.to_a
    
    required.collect! { |a| [ a[0], a[1] * multiplier - (players[a[0]] ||= []).size ] } # players = { scout => [a, b], soldier => [b] }
    required.reject! { |a| a[1] <= 0 } # Remove any negative or zero values
    Hash[required]
  end

  def list_classes_needed
    output = classes_needed(get_classes, Team_count).to_a
    output.collect! { |a| "#{ a[1] } #{ a[0] }" } # Format the output

    message "#{ make_title "Required classes:" } #{ output.join(", ") }"
  end

  def minimum_players?
    return false if @players.size < Team::Max_size * Team_count
    return classes_needed(get_classes, Team_count).empty?
  end
end