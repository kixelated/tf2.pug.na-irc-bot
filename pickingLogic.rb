module PickingLogic
  def choose_captains
    possible_captains = get_classes["captain"]

    #signups = {}
    Const::Team_count.times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)
      
      @captains << captain
      @teams << Team.new(captain, Const::Team_names[i], Const::Team_colours[i])
      @players.delete captain

      notice captain, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command."
    end
    
=begin
    @captains.each { |k, v| signups[k] = @players.delete k }
    
    classes_needed(get_classes, Const::Team_count).each do |k, v|
      if k == "medic"
        @teams.each do |team|
          if signups[team.captain].include? "medic"
            notice team.captain, "You have been designated as a medic due to the low avaliability of medics."
            team.players.each { |k, v| team.players[k] = "medic" if k == team.captain } 
          end
        end
      end
    end
=end

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
    @players.key? player and Const::Team_classes.key? player_class and player_class != "captain"
  end
  
  def pick_player_avaliable? player_class
    classes_needed(current_team.get_classes).key? player_class # playersLogic.rb
  end
  
=begin
  def pick_medic? player, player_class
    if player_class != "medic" and @players[player].include? "medic"
      medics = 0
      @teams.each { |team| medics = medics + 1 if (team.get_classes["medic"] ||= []).size > 0 }
      message "#{ medics } medics have been picked already, #{ (Const::Team_size * Const::Team_classes["medic"] - medics) } medics still needed."
      message "There are #{ (get_classes["medic"] ||= []).size } medics left, and you would take one of them?"
      
      return true if Const::Team_size * Const::Team_classes["medic"] - medics >= (get_classes["medic"] ||= []).size - 1
    end
    false
  end
=end

  def pick_player user, player, player_class
    return notice(user, "Picking has not started.") unless picking? # stateLogic.rb
    return notice(user, "It is not your turn to pick.") unless can_pick? user

    player_class.downcase!
    
    unless pick_player_valid? player, player_class
      return notice(user, "Invalid pick #{ player } as #{ player_class }.") unless player.nick.to_i
      
      player = @lookup[player.nick.to_i]

      return notice(user, "Invalid pick #{ player } as #{ player_class }.") unless pick_player_valid? player, player_class
    end
    
    return notice(user, "That class is full.") unless pick_player_avaliable? player_class
    #return notice(user, "That pick is unavaliable, as that player is needed to play medic.") if pick_medic? player, player_class

    current_team.players[player] = player_class
    @players.delete player
    
    message "#{ current_team.my_colourize user.to_s } picked #{ player.to_s } as #{ player_class }"
    
    @pick += 1
    
    if @pick + Const::Team_count >= Const::Team_size * Const::Team_count
      announce_teams
      start_server # serverLogic.rb
      end_game # stateLogic.rb
    else 
      tell_captain
    end
  end
  
  def announce_teams
    @teams.each do |team|
      message team.to_s
    end
  
    @teams.each do |team|
      team.players.each do |user, clss| 
        private user, "You have been picked for #{ team.name } as #{ clss }. The server info is: #{ @server.connect_info }" 
      end
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
    num % Const::Team_count
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when @Const::Team_count > 2
    ((num + Const::Team_count / 2) / Const::Team_count) % Const::Team_count
  end
end