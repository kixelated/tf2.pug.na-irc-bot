module PickingLogic
  def picking? 
    @state >= 1 # kind of crude
  end
  
  def attempt_picking
    start_picking if !picking? and minimum_players?
  end
  
  def start_picking
    possible_captains = @players.invert_arr["captain"]
    @team_count.times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)
      
      @captains << captain
      @teams << { captain => "captain" }
      @players.delete captain
    end
    
    msg "Captains are [#{ @captains.join(", ") }]"
    tell_captain # inform the captain that it is their pick
    
    @state = 2 # skips over 1 at the moment
  end
  
  def tell_captain
    user = @captains[@pick_index]
    classes = @teams[@pick_index].invert_pro
    
    # Displays the classes that are not yet full for this team
    priv user, "It is your turn to pick."
    @classes_count.each do |k, v|
      diff = v - (classes[k] ||= []).size
      priv user, "#{diff} #{ k }: [#{ @players.invert_arr[k].join(", ") }]" if diff > 0
    end
  end
  
  def list_captain user
    return priv(user, "Picking has not started.") unless picking?
    
    msg "It is #{ @captains[@pick_index].to_s }'s pick"
  end
  
  def can_pick? user
    @captains[@pick_index] == user
  end
  
  def pick_player_valid? player, player_class
    @players.key? player and @classes_count.key? player_class
  end
  
  def pick_player_captain? user, player
    user != player and @captains.include? player
  end
  
  def pick_player_full? player_class
    count = (@teams[@pick_index].invert_pro[player_class] ||= []).size
    @classes_count[player_class] <= count
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
    
    if @pick + @team_count == @team_size * @team_count
      print_teams
      start_game
      
      msg "Game started. Add to the pug using the !add command."
    else 
      tell_captain
    end
  end
  
  def print_teams
    @teams.each do |team|
      msg "#{ team.each { |k, v| "#{ k } => #{ v.to_s }" }}"
    end
  end
  
  def sequential num
    # 0 1 0 1 0 1 0 1 ...
    num % @team_count
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when @team_count > 2
    ((num + 1) / @team_count) % @team_count
  end
end