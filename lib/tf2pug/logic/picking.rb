require 'tf2pug/database'

module PickingLogic
  def self.pick_player(captain, pick, clss)
    pugs = Pug.all(:state_pug => :picking) # possible to have multiple picking processes
    return Irc.notice(captain, "Picking has not started.") if pugs.empty?
    
    captain_u = User.find_player(captain)
    
    pug = pugs.detect { |pug| pug.signups.first(:user => captain_u) } # select the pug this player is signed up for
    return Irc.notice(captain, "You are not able to pick.") unless pug
    
    matchup = pug.get_matchup(&pick_format)
    return Irc.notice(captain, "It is not your turn to pick.") unless matchup.team.leader == captain_u
    
    tfclass = Tfclass.first(:name => clss.downcase)
    return Irc.notice(captain, "Invalid class #{ clss }.") unless tfclass

    id = pick.nick.to_i
    user = pug.signups.first(:id => id) if id > 0 # if pick by number
    user = User.find_player(pick) unless user
    
    return Irc.notice(captain, "Could not find user #{ pick.nick }.") unless user
    return Irc.notice(captain, "#{ pick.nick } is not added to this pug.") unless pug.signups.first(:user => user)
    return Irc.notice(captain, "#{ pick.nick } has already been picked.") unless pug.picks.first(:user => user)
    
    remaining = tfclass.pug - matchup.picks.count(:tfclass => tfclass)
    return Irc.notice(user, "The class #{ clss } is full.") unless remaining > 0
    
    tfmedic = Tfclass.first(:name => "medic")
    if tfclass != tfmedic and pug.signups.first(:user => user, :tfclass => tfmedic) # only check if player is not picked as medic and was added as medic
      #return Irc.notice(user, "You cannot pick one of the remaining medics.") # TODO
    end

    matchup.add_pick(user, tfclass)
    
    Irc.message "#{ captain.nick } picked #{ pick.nick } as #{ clss }"
  end
  
=begin
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
=end
  def self.pick_format pug
    num = pug.pick_num - 2 # factors in captains
    staggered(num) + 1 # factors in zero-indexing
  end

  def self.sequential num
    # 0 1 0 1 0 1 0 1 ...
    num % 2
  end

  def self.staggered num
    # 0 1 1 0 0 1 1 0 ...
    ((num + 1) / 2) % 2
  end
end
