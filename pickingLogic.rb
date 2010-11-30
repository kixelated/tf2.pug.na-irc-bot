module PickingLogic
  def choose_captains
    output = []
    possible_captains = @players.invert_arr["captain"]
    
    @team_count.times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)
      
      @teams << { captain => "captain" }
      @captains << captain
      @players.delete captain
      
      output << team_colour(captain.nick, i)
    end

    message "Captains are #{ output.join(", ") }"
  end

  def tell_captain
    # Displays the classes that are not yet full for this team
    notice current_captain, "It is your turn to pick."
    
    temp = @players.invert_arr
    remaining_classes(current_team.invert_pro_size).each do |k, v|
      notice current_captain, "#{ v } #{ k }: #{ temp[k].join(", ") if temp[k] }"
    end
  end
  
  def list_captain user
    return notice(user, "Picking has not started.") unless picking?
 
    message "It is #{ current_captain.to_s }'s turn to pick"
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
  
  def pick_player user, pick
    return notice(user, "Picking has not started.") unless picking?
    return notice(user, "It is not your turn to pick.") unless can_pick? user
    return notice(user, "Invalid pick format. !pick user class") unless pick.size == 2
  
    player = User(pick[0])
    player_class = pick[1]

    return notice(user, "Invalid pick #{player} as #{player_class}.") unless pick_player_valid? player, player_class
    return notice(user, "That class is full.") unless pick_player_avaliable? player_class

    current_team[player] = player_class
    @players.delete player
        
    @pick += 1
    
    if @pick + @team_count >= @team_size * @team_count
      announce_teams
      start_server
      end_picking
    else 
      tell_captain
    end
  end
  
  def team_colour msg, id
    colour_end + colour_start(@team_colours[id], 1) + msg + colour_end + colour_default
  end

  def announce_teams
    @teams.each_with_index do |team, i|
      temp = []
      team.each do |k, v| 
        message k, "You have been picked for #{ @team_names[i] } as #{ v }. The server info is: #{ connect_info }" 
        temp << "#{ k } as #{ team_colour(v.to_s, i) }"
      end
      
      message "#{ team_colour(@team_names[i], i) }:" + " #{ temp.join(", ") }"
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