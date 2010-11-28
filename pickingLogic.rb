module PickingLogic
  def picking? 
    @state >= 1
  end
  
  def start_picking
    if !picking? and minimum_players?
      possible_captains = Util::hash_invert_a(@players)["captain"]
      for i in (1..2)
        captain = possible_captains.delete_at(rand(possible_captains.length))
        
        @captains << captain
        @teams << { captain => "captain" }
        @players.delete captain
      end
      
      msg "Captains are #{@captains[0].nick} and #{@captains[1].nick}"
      tell_captain
      
      @state = 1
    end
  end
  
  def tell_captain
    remaining = []
    counts = Util::hash_count(@teams[@pick_index])
    
    @team_classes.each do |k, v|
      count = counts[k] || 0
      remaining << "#{v - count} #{k}" if v != count
    end
    
    priv @captains[@pick_index], "It is your turn to pick. Remaining: #{remaining.join(", ")}"
  end
  
  def list_captain user
    return priv(user, "Picking has not started.") unless picking?
    
    msg "It is #{@captains[@pick_index].nick}'s pick"
  end
  
  def can_pick? user
    @captains[@pick_index] == user
  end
  
  def pick_player_valid? player, player_class
    @players.key? player and @team_classes.key? player_class
  end
  
  def pick_player_captain? user, player
    user != player and @captains.include? player
  end
  
  def pick_player_full? player_class
    count = Util::hash_count(@teams[@pick_index])[player_class] || 0
    count + 1 > @team_classes[player_class]
  end
  
  def pick_player user, player, player_class
    return priv(user, "Picking has not started.") unless picking?
    return priv(user, "It is not your turn to pick.") unless can_pick? user
    return priv(user, "Invalid pick.") unless pick_player_valid? player, player_class
    return priv(user, "That class is full.") if pick_player_full? player_class

    @teams[@pick_index][player] = player_class
    @players.delete player
        
    @pick += 1
    @pick_index = staggered @pick
    
    if @pick + 2 == @team_size * 2
      print_teams
      start_game
      
      msg "Game started. Add to the pug using the !add command."
    else 
      tell_captain
    end
  end
  
  def print_teams
    @teams.each do |team|
      players = []
      team.each do |k, v|
        players << "\"#{k.nick}\" => #{v}"
      end
      
      msg "Team: #{players.join(", ")}"
    end
  end
  
  def sequential num
    num % 2
  end
  
  def staggered num
    ((num + 1) / 2) % 2
  end
end