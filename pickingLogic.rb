module PickingLogic
  def choose_captains
    possible_captains = get_classes["captain"]
    
    Variables::Team_count.times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)

      @teams << Team.new(captain, Variables::Team_names[i], Variables::Team_colours[i])
      @players.delete captain
    end

    output = @teams.collect { |team| team.my_colourize team.captain.to_s }
    message "Captains are #{ output.join(", ") }"
  end
  
  def update_lookup
    @lookup.clear
    @players.to_a.each_with_index { |a, i| @lookup[i + 1] = a[0] }
  end

  def tell_captain
    notice current_captain, "It is your turn to pick."

    # Displays the classes that are not yet full for this team
    classes_needed(current_team.get_classes).each do |k, v| # playersLogic.rb
      output = (get_classes[k] ||= []).collect { |player| "(#{ @lookup.invert[player] }) #{ player.to_s }" }
      notice current_captain, "#{ v } #{ k }: #{ output.join(", ") }"
    end
  end
  
  def list_captain user
    return notice(user, "Picking has not started.") unless picking? # stateLogic.rb
 
    message "It is #{ current_captain.to_s }'s turn to pick"
  end
  
  def can_pick? user
    current_captain == user
  end
  
  def pick_player_valid? player, player_class
    @players.key? player and Team::Minimum.key? player_class
  end
  
  def pick_player_avaliable? player_class
    classes_needed(current_team.get_classes).key? player_class # playersLogic.rb
  end
  
  def pick_player user, player, player_class
    return notice(user, "Picking has not started.") unless picking? # stateLogic.rb
    return notice(user, "It is not your turn to pick.") unless can_pick? user

    player_class.downcase!
    
    unless pick_player_valid? player, player_class
      player = @lookup[pick[0].to_i] if pick[0].to_i

      return notice(user, "Invalid pick #{ player } as #{ player_class }.") unless pick_player_valid? player, player_class
    end
    
    return notice(user, "That class is full.") unless pick_player_avaliable? player_class

    current_team.players[player] = player_class
    @players.delete player
    
    message "#{ user.to_s } picked #{ player.to_s } as #{ player_class }" if pick[0].to_i
    
    @pick += 1
    
    if @pick + Variables::Team_count >= Team::Max_size * Variables::Team_count
      announce_teams
      start_server # serverLogic.rb
      end_picking # stateLogic.rb
    else 
      tell_captain
    end
  end
  
  def replace_player user, replacement
    @players[replacement] = @players.delete(user) if @players.key? user
    @teams.each do |team|
      team.players[replacement] = team.players.delete(user) if team.players.key? user
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
    num % Variables::Team_count
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when @Variables::Team_count > 2
    ((num + Variables::Team_count / 2) / Variables::Team_count) % Variables::Team_count
  end
end