module PickingLogic
  def picking? 
    @state >= 1 # kind of crude
  end
  
  def picking_team
	if @pick_index == 0
		return blu
	else
		return red
	end
  end
  
  def attempt_picking
    start_picking if !picking? and minimum_players?
  end
  
  def start_picking
    possible_captains = @players.invert_arr["captain"]
    captain = possible_captains.delete_at rand(possible_captains.length)
    @blu = Team.new(captain)
    @players.delete captain
    
	captain = possible_captains.delete_at rand(possible_captains.length)
    @red = Team.new(captain)
    @players.delete captain	
    
    msg "Captains are:" + blu.captain + "and" + red.captain
    tell_captain # inform the captain that it is their pick
    
    @state = 2 # skips over 1 at the moment
  end
  
  def tell_captain
	    user = picking_team.captain
    # Displays the classes that are not yet full for this team
		message = "You have "
		picking_team.classes_count.each do |class_name, count|
			message << count + " " + class_name + "; "
		end
		msg message
  end
	
  def list_captain user
    return priv(user, "Picking has not started.") unless picking?
    
    msg "It is #{ picking_team.captain }'s pick"
  end
  
  def can_pick? user
    picking_team.captain == user
  end
  
  def pick_player_valid? player, player_class
    @players.key? player and @classes_count.key? player_class
  end
  
  def pick_player_captain? user, player
    user != player and @captains.include? player
  end
  
  def pick_player_full? player_class
    picking_team.classes_count[player_class] != 0
  end
  
  def pick_player user, player, player_class
    return priv(user, "Picking has not started.") unless picking?
    return priv(user, "It is not your turn to pick.") unless can_pick? user
    return priv(user, "Invalid pick.") unless pick_player_valid? player, player_class
    return priv(user, "That class is full.") if pick_player_full? player_class

    picking_team.addplayer player, player_class
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
    blu.print_teams
    red.print_teams
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
