module PlayersLogic
  def add_player user, cs
    remove_player user
  
    cs.each do |c|
      (@players[user] ||= []) << c if @classes_count.key? c and not (@players.key? user and @players[user].include? c)
    end
    
    @players.key? user
  end

  def remove_player user
    (@players.delete user) != nil
  end
  
  def list_players
    msg "#{ @players.length } users added: [#{ @players.keys.join(", ") }]"
  end

  def list_players_detailed
    @players.invert_arr.each do |k, v|
      msg "#{ k.capitalize }: [#{ v.join(", ") }]"
    end
  end
  
  def remaining_classes hash, multiplier = 1
    @classes_count.reject do |k, v| 
      v * multiplier <= (hash[k] || 0)
    end
  end

  def list_classes_needed
    if !picking?
      output = remaining_classes(@players.invert_arr_size, @team_count)
      msg "Required classes: [#{ output.keys.join(", ") }]" unless output.empty?
    end
  end

  def minimum_players?
    # false if the total number of players is not enough
    return false if @players.size < @team_size * @team_count
    
    # false if any of the classes do not meet the requirements
    remaining_classes(@players.invert_arr_size, @team_count).empty?
  end
end