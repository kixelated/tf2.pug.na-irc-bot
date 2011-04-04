require 'tf2pug/database'

module PickingLogic
  def self.pick_player(captain, pick, clss)
    pug = Pug.last(:state_pug => :picking)
  
    # return Irc.notice(captain, "Picking has not started.") unless state?("picking") # TODO
    return Irc.notice(captain, "It is not your turn to pick.") unless current_captain == User.find_player(captain)

    id = pick.nick.to_i
    user = pug.signups.first(:id => id) if id > 0 # if pick by number
    user = User.find_player(pick) unless user
    
    return Irc.notice(captain, "Could not find user #{ pick.nick }.") unless user
    
    tfclass = Tfclass.first(:name => clss.downcase)
    return Irc.notice(captain, "Invalid class #{ clss }.") unless tfclass

    return Irc.notice(user, "The class #{ clss } is full.") unless pick_class_avaliable?(tfclass)
    return Irc.notice(user, "You cannot pick one of the remaining medics.") if pick_medic_conflicting?(user, tfclass)

    pug.add_pick(user, team, tfclass)
    pug.remove_signup(user)
    
    Irc.message "#{ captain.nick } picked #{ pick.nick } as #{ clss.name }"
  end

  def self.pick_num
    Pug.last(:state_pug => :picking).picks.count
  end

  def self.tell_captain
    Irc.notice current_captain.nick, "It is your turn to pick."
  end

  def self.list_captain
    return Irc.message("Picking has not started.") unless state?("picking") # TODO

    Irc.message "It is #{ current_captain.nick }'s turn to pick"
  end

  # TODO: !random
  def self.pick_random user, clss
    classes = get_classes[clss]
    nick = classes[rand(classes.length)]

    pick_player user, nick, clss
  end

  def self.can_pick? user
    current_captain == user
  end

  def self.pick_class_valid? clss
    Constants.teams['classes'].key? clss
  end

  def self.pick_class_avaliable? clss
    classes_needed(current_team.get_classes, 1).key? clss # logic/players.rb
  end

  def self.pick_medic_conflicting? nick, clss
    return false unless @signups[nick].include? "medic"

    needed = 0
    medics = get_classes['medic'].size - 1 # the current pick is a medic

    @teams.each { |team| needed += 1 unless team.signups.values.include?("medic") or @signups_all[team.captain].include?("medic") }
    needed -= 1 if clss == "medic" and !@signups_all[current_team.captain].include? "medic" # special case where team has a captain who can med

    return medics < needed
  end

  def self.next_pick
    @pick += 1

    if @pick >= Constants.teams['total'] - Constants.teams['count']
      final_pick
    else
      tell_captain
    end
  end

  def self.final_pick
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

  def self.update_captains
    @teams.each do |team|
      team.signups[team.captain] = classes_needed(team.get_classes, 1).keys.first
    end
  end

  # I hate this function
  def self.create_match
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

  def self.print_teams
    @teams.each do |team|
      Irc.message team.format_team
    end
  end

  def self.announce_teams
    @teams.each do |team|
      team.signups.each do |nick, clss|
        private nick, "You have been picked for #{ team.format_name 0 } as #{ clss }. The server info is: #{ @server.connect_info }"
      end
    end
  end

  def self.list_format
    output = []
    (Constants.teams['total'] - Constants.teams['count']).times do |i|
      output << (colourize "#{ i }", Constants.teams['details'][pick_format(i)]['colour'])
    end
    Irc.message "The picking format is: #{ output * " " }"
  end

  def self.current_captain
    current_team.captain
  end

  def self.current_team
    @teams[pick_format @pick]
  end

  def self.pick_format num
    staggered num
  end

  def self.sequential num
    # 0 1 0 1 0 1 0 1 ...
    num % Constants.teams['count']
  end

  def self.staggered num
    # 0 1 1 0 0 1 1 0 ...
    # won't work as expected when Constants.teams['count'] > 2
    ((num + 1) / Constants.teams['count']) % Constants.teams['count']
  end

  def self.hybrid num
    # 0 1 0 1
    #         1 0 0 1 1 0 ...
    return sequential(num) if num < 4
    staggered(num - 2)
  end
end
