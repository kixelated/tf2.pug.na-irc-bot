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
    message "#{ @players.size } #{ @players.keys.join(", ") }"
  end

  def list_players_detailed
    @players.invert_arr.each do |k, v|
      message "#{ k }: #{ v.join(", ") }"
    end
  end

  def list_classes_needed
    # The number of remaining players required is the difference between, the total number needed times the number of teams, and the number of players currently amassed
    # Negative values are thrown out, as that indicates a surplus
    temp = @players.invert_arr.collect { |clss| clss.size }
    temp = (Team::minimum * Team::max_size - temp).reject { |x| x < 0 } 
  
    output = []
    temp.each do |k, v|
      output << "#{ v } #{ k }"
    end
    
    message "Required classes: #{ output.join(", ") }" unless output.empty?
  end

  def minimum_players?
    return false if @players.size < Team::max_size * Constants::team_count
    return remaining_classes(Team::minimum * Constants::team_count, @players.invert_arr).empty?
  end
end