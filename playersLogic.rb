module PlayersLogic
  def add_player user, classes
    return notice user, "You cannot add at this time, please wait for picking to end." unless can_add?
    
    classes.collect! { |clss| clss.downcase }
    classes.reject! { |clss| not Team::classes.key? clss }
  
    return notice user, "Invalid classes, you have not been added." if classes.empty?
    
    @players[user] = classes
  end

  def remove_player user
    return notice user, "You cannot remove at this time." unless can_remove?
  
    @players.delete user
  end
  
  def list_players
    message make_title("#{@players.length} users added:") + " #{ @players.keys.join(", ") } "
  end

  def list_players_detailed
    @players.invert_arr.each do |k, v|
      message make_title("#{ k }:", 2) + " #{ v.join(", ") } "
    end
  end
  
  def remaining_classes hash, multiplier = 1
    @team_classes.reject do |k, v| 
      v * multiplier <= (hash[k] || 0)
    end
  end

  def list_classes_needed
    if can_add?
      output = remaining_classes(@players.invert_arr_size, @team_count)
      message make_title("Required classes:", 2) + " #{ output.keys.join(", ") }" unless output.empty?
    end
  end

  def minimum_players?
    # false if the total number of players is not enough
    return false if @players.size < @team_size * @team_count
    
    # false if any of the classes do not meet the requirements
    remaining_classes(@players.invert_arr_size, @team_count).empty?
  end
end