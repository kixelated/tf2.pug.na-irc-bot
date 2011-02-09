require_relative '../model/team'
require_relative '../model/match'
require_relative '../model/player'
require_relative '../model/pick'
require_relative '../model/user'

module PickingLogic
  def start_picking
    update_lookup
    choose_captains
    tell_captain
  end

  def choose_captains
    @signups_all = @signups.dup # so we have a copy of the signups
  
    captains = get_classes["captain"].shuffle
    captains.sort_by! { |nick| @signups[nick].include?("medic") ? 0 : 1 } # give medics priority
    captains = captains.first const["teams"]["count"] # select first 2* captains

    captains.each_with_index do |captain, i|
      team = Team.new
      team.set_captain captain
      team.set_details const["teams"]["details"][i]

      @teams << team
      @signups.delete captain
    end

    output = @teams.collect { |team| team.my_colourize team.captain }
    message "Captains are #{ output * ", " }"

    captains.each do |captain|
      notice captain, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command. Remember, you will play the class that you do not pick, so be sure to pick a medic if you do not wish to play medic."
    end
  end

  def update_lookup
    @lookup.clear
    @signups.keys.each_with_index { |nick, i| @lookup[i + 1] = nick }
  end

  def tell_captain
    notice current_captain, "It is your turn to pick."

    classes = get_classes
    lookup_i = @lookup.invert

    # Display all of the players
    output = @signups.keys.collect { |player| "(#{ lookup_i[player] }) #{ player }" }
    notice current_captain, "#{ bold rjust("all: ") } #{ output * ", " }"

    # Displays the classes that are not yet full for this team
    classes_needed(current_team.get_classes, 1).each do |clss, count| # logic/players.rb
      output = classes[clss].collect { |player| "(#{ lookup_i[player] }) #{ player }" }
      notice current_captain, "#{ bold rjust("#{ count } #{ clss }: ") } #{ output * ", " }"
    end
  end

  def list_captain user
    return notice(user, "Picking has not started.") unless state? "picking" # logic/state.rb

    message "It is #{ current_captain }'s turn to pick"
  end

  def pick_random user, clss
    classes = get_classes[clss]
    nick = classes[rand(classes.length)]

    pick_player user, nick, clss
  end

  def can_pick? nick
    current_captain == nick
  end

  def find_player player
    temp = @signups.keys.reject { |k| k.downcase != player.downcase }
    temp.first unless temp.empty?
  end

  def pick_class_valid? clss
    const["teams"]["classes"].key? clss
  end

  def pick_class_avaliable? clss
    classes_needed(current_team.get_classes, 1).key? clss # logic/players.rb
  end

  def pick_medic_conflicting? nick, clss
    return false unless @signups[nick].include? "medic"

    needed = 0
    medics = get_classes["medic"].size - 1 # the current pick is a medic

    @teams.each { |team| needed += 1 unless team.signups.values.include?("medic") or @signups_all[team.captain].include?("medic") }
    needed -= 1 if clss == "medic" and !@signups_all[current_team.captain].include? "medic" # special case where team has a captain who can med

    return medics < needed
  end

  def pick_player user, nick, clss
    return notice(user, "Picking has not started.") unless state? "picking" # logic/state.rb
    return notice(user, "It is not your turn to pick.") unless can_pick? user.nick

    clss.downcase!
    player = find_player nick

    unless player
      player = @lookup[nick.to_i] if nick.to_i > 0
      return notice(user, "Could not find #{ nick }.") unless player
      return notice(user, "#{ player } has already been picked.") unless @signups.key? player
    end

    return notice(user, "Invalid class #{ clss }.") unless pick_class_valid? clss
    return notice(user, "The class #{ clss } is full.") unless pick_class_avaliable? clss
    return notice(user, "You cannot pick one of the remaining medics.") if pick_medic_conflicting? player, clss

    current_team.signups[player] = clss
    @signups.delete player
    @pick_order << player
    
    message "#{ current_team.my_colourize user.nick } picked #{ player } as #{ clss }"

    next_pick
  end

  def next_pick
    @pick += 1

    if @pick >= const["teams"]["total"] - const["teams"]["count"]
      final_pick
    else
      tell_captain
    end
  end

  def final_pick
    end_picking

    server = Thread.new { find_server }

    update_captains
    print_teams # update_captains (indicates dependencies)
    create_match # update_captains

    server.join

    announce_server # find_server
    announce_teams # update_captains, find_server
    
    list_players
    end_game
  end

  def update_captains
    @teams.each do |team|
      team.signups[team.captain] = classes_needed(team.get_classes, 1).keys.first
    end
  end

  # I hate this function
  def create_match
    match = Match.create(:time => Time.now)
    captains = @teams.collect { |team| team.captain }
    
    team_lookup = {}
    @teams.each do |team|
      team.save # teams have not been saved up to this point just in case of !endgame
      match.teams << team
      
      # cache team signups for easy lookup
      team.signups.each_key { |nick| team_lookup[nick] = team }
    end
    
    # order matters, as the id will determine the pick order
    (captains + @pick_order + @signups.keys).each do |nick|
      u = @auth[nick]
      team = team_lookup[nick] # returns nil for fat kids

      classes = []
      classes << team.signups[nick] if team
      classes << "captain" if captains.include? nick
      
      team.users << u if team
      player = u.players.create(:match => match, :team => team)
      
      classes.each { |clss| player.picks.create(:tfclass => Tfclass.find_by_name(clss)) }
      @signups_all[nick].each { |clss| player.signups << Tfclass.find_by_name(clss) }
    end
  end

  def print_teams
    @teams.each do |team|
      message team.format_team
    end
  end

  def announce_teams
    @teams.each do |team|
      team.signups.each do |nick, clss|
        private nick, "You have been picked for #{ team.format_name 0 } as #{ clss }. The server info is: #{ @server.connect_info }"
      end
    end
  end

  def list_format
    output = []
    (const["teams"]["total"] - const["teams"]["count"]).times do |i|
      output << (colourize "#{ i }", const["teams"]["details"][pick_format(i)]["colour"])
    end
    message "The picking format is: #{ output * " " }"
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
