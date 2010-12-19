require '../model/team.rb'
require '../model/match.rb'
require '../model/player.rb'
require '../model/stat.rb'
require '../model/user.rb'

module PickingLogic
  def choose_captains
    possible_captains = get_classes["captain"]

    const["teams"]["count"].times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)
      
      @teams << Team.new(
        :name => const["teams"]["details"][i]["name"], 
        :colour => const["teams"]["details"][i]["colour"], 
        :captain => captain
      )
      @signups.delete captain

      notice captain, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command."
      notice captain, "Remember, you will play the class that you do not pick, so be sure to pick a medic if you do not wish to play medic."
    end
    
    output = @teams.collect { |team| team.colourize captain }
    message "Captains are #{ output.join(", ") }"
  end
  
  def update_lookup
    @lookup.clear
    @signups.keys.each_with_index { |user, i| @lookup[i] = user }
  end

  def tell_captain
    notice current_captain, "It is your turn to pick."

    classes = get_classes
    lookup_i = @lookup.invert
    
    # Displays the classes that are not yet full for this team
    classes_needed(current_team.get_classes).each do |k, v| # logic/players.rb
      output = classes[k].collect { |player| "(#{ lookup_i[player] }) #{ player }" }
      notice current_captain, "#{ bold rjust("#{ v } #{ k }:") } #{ output.join(", ") }"
    end
  end
  
  def list_captain user
    return notice(user, "Picking has not started.") unless state? "picking" # logic/state.rb
 
    message "It is #{ current_captain }'s turn to pick"
  end

  def can_pick? user
    current_captain == user
  end
  
  def pick_player_valid? player, player_class
    @signups.key? player and const["teams"]["classes"].key? player_class
  end
  
  def pick_player_avaliable? player_class
    classes_needed(current_team.get_classes).key? player_class # logic/players.rb
  end

  def pick_player user, player, player_class
    return notice(user, "Picking has not started.") unless state? "picking" # logic/state.rb
    return notice(user, "It is not your turn to pick.") unless can_pick? user

    player.downcase!
    player_class.downcase!
    
    unless pick_player_valid? player, player_class
      player = @lookup[player.to_i] if player.to_i
    
      return notice(user, "Invalid pick #{ player } as #{ player_class }.") unless player and pick_player_valid? player, player_class
    end
    
    return notice(user, "That class is full.") unless pick_player_avaliable? player_class

    current_team.signups[player] = player_class
    @signups.delete player
    
    @pick += 1
    
    message "#{ current_team.colourize user } picked #{ player } as #{ player_class }"
    
    if @pick >= const["teams"]["total"] - const["teams"]["count"]
      final_pick
    else 
      tell_captain
    end
  end
  
  def final_pick
    end_picking # logic/state.rb
    update_captains
    
    create_match
    start_server # logic/server.rb

    announce_teams
    announce_server # logic/server.rb
    
    end_game # logic/state.rb
  end
  
  def update_captains
    @teams.each do |team|
      team.signups[team.captain] = classes_needed(team.get_classes).keys.first
    end
  end
 
  def create_match
    match = Match.create
    
    @teams.each do |team|
      team.save # teams have not been saved up to this point just in case of !endgame
      match.teams << team
      
      # Create each player's statistics
      team.signups.each do |user, clss|
        p = create_player user, match, team
        
        create_stat p, "captain" if user == team.captain # captain gets counted twice
        create_stat p, clss
      end
    end
  end
  
  def create_player user, match, team
    User.find_by_auth(@auth[user]).players.create(:match => match, :team => team)
  end
  
  def create_stat player, clss
    player.stats.create(:class => clss)
  end
  
  def announce_teams
    @teams.each do |team|
      message team.formatted
    end
  
    @teams.each do |team|
      team.signups.each do |user, clss|
        private user, "You have been picked for #{ team.colourize team, 0 } as #{ clss }. The server info is: #{ @server.connect_info }" 
      end
    end
  end
  
  def list_format
    output = Array.new(const["teams"]["total"] - const["teams"]["count"]).collect do |i| 
      output << (colourize "#{ i }", const["teams"]["details"][pick_format(i)]["colour"])
    end
    message "The picking format is: #{ output.join(" ") }"
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
    num % const["teams"]["count"]
  end
  
  def staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when const["teams"]["count"] > 2
    ((num + 1) / const["teams"]["count"]) % const["teams"]["count"]
  end
  
  def hybrid num
    # 0 1 0 1
    #         1 0 0 1 1 0 ...
    return sequential(num) if num < 4
    staggered(num - 2)
  end
end
