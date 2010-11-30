module PickingLogic
  def tell_captain
    # Displays the classes that are not yet full for this team
    priv current_captain, "It is your turn to pick."
    
    temp = @players.invert_arr
    remaining_classes(current_team.invert_pro_size).each do |k, v|
      priv current_captain, "#{ v } #{ k }: #{ temp[k].join(", ") if temp[k] }"
    end
  end
  
  def list_captain user
    return priv(user, "Picking has not started.") unless picking?
 
    msg "It is #{ current_captain.to_s }'s pick"
  end
  
  def can_pick? user
    current_captain == user
  end
  
  def pick_player_valid? player, player_class
    @players.key? player and @team_classes.key? player_class
  end
  
  def pick_player_avaliable? player_class
    remaining_classes(current_team).key? player_class
  end
  
  def pick_player user, player, player_class
    return priv(user, "Picking has not started.") unless picking?
    return priv(user, "It is not your turn to pick.") unless can_pick? user
    return priv(user, "Invalid pick.") unless pick_player_valid? player, player_class
    return priv(user, "That class is full.") unless pick_player_avaliable? player_class

    current_team[player] = player_class
    @players.delete player
        
    @pick += 1
    
    if @pick + @team_count >= @team_size * @team_count
      end_picking
      print_teams
      
      msg "Game started. Add to the pug using the !add command."
    else 
      tell_captain
    end
  end

  def print_teams
    @teams.each_with_index do |team, i|
      temp = []
      team.each { |k, v| temp << "#{ k } => #{ v.to_s }" }
      msg "#{ @team_colours[i].capitalize } team: #{ temp.join(", ") }"
    end
  end
  
  def current_captain
    @captains[pick_format @pick]
  end
  
  def current_team
    @teams[pick_format @pick]
  end
  
  def pick_format num
    staggered num
  end
  
  def sequential num
    # 0 1 0 1 0 1 0 1 ...
    num % @team_count
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when @team_count > 2
    ((num + @team_count / 2) / @team_count) % @team_count
  end
end