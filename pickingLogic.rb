module PickingLogic
  def choose_captains
    possible_captains = get_classes["captain"]
    
    Constants::Team_count.times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)

      @teams << Team.new(captain, Constants::Team_names[i], Constants::Team_colours[i])
      @players.delete captain
    end

    output = @teams.collect { |team| team.my_colourize team.captain.to_s }
    message "Captains are #{ output.join(", ") }"
  end

  def tell_captain
    notice current_captain, "It is your turn to pick."

    # Displays the classes that are not yet full for this team
    classes_needed(current_team.get_classes).each do |k, v|
      notice current_captain, "#{ v } #{ k }: #{ get_classes[k].join(", ") }"
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
    @players.key? player and Team::Minimum.key? player_class
  end
  
  def pick_player_avaliable? player_class
    classes_needed(current_team.get_classes).key? player_class
  end
  
  def pick_player user, pick
    return notice(user, "Picking has not started.") unless picking?
    return notice(user, "It is not your turn to pick.") unless can_pick? user
    return notice(user, "Invalid pick format. !pick user class") unless pick.size == 2
  
    player = User(pick[0])
    player_class = pick[1].downcase

    return notice(user, "Invalid pick #{ player } as #{ player_class }.") unless pick_player_valid? player, player_class
    return notice(user, "That class is full.") unless pick_player_avaliable? player_class

    current_team.players[player] = player_class
    @players.delete player
        
    @pick += 1
    
    if @pick + Constants::Team_count >= Team::Max_size * Constants::Team_count
      announce_teams
      start_server
      end_picking
    else 
      tell_captain
    end
  end

  def announce_teams
    @teams.each_with_index do |team, i|
      team.players.each do |user, v| 
        private user, "You have been picked for #{ team.name } as #{ v }. The server info is: #{ connect_info }" 
      end
      
      message team.to_s
    end
  end
  
  def current_captain
    current_team.captain
  end
  
  def current_team
    @teams[pick_format @pick]
  end
  
  def pick_format num
    staggered num
  end
  
  def sequential num
    # 0 1 0 1 0 1 0 1 ...
    num % Constants::Team_count
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when @Team_count > 2
    ((num + Constants::Team_count / 2) / Constants::Team_count) % Constants::Team_count
  end
end