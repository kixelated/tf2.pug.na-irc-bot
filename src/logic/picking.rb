require_relative '../model/team'
require_relative '../model/match'
require_relative '../model/player'
require_relative '../model/stat'
require_relative '../model/user'

module PickingLogic
  def choose_captains
    possible_captains = get_classes["captain"]
    @signups_all = @signups.reject { |k, v| false } # Ghetto way of copying a hash

    const["teams"]["count"].times do |i|
      captain = possible_captains.delete_at rand(possible_captains.length)

      team = Team.new
      team.set_captain captain
      team.set_details const["teams"]["details"][i]

      @teams << team
      @signups.delete captain
    end

    output = @teams.collect { |team| team.my_colourize team.captain }
    message "Captains are #{ output * ", " }"

    @teams.each do |team|
      notice team.captain, "You have been selected as a captain. When it is your turn to pick, you can choose players with the '!pick num' or '!pick name' command. Remember, you will play the class that you do not pick, so be sure to pick a medic if you do not wish to play medic."
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
    notice current_captain, "#{ bold "all: " } #{ output * ", " }"

    # Displays the classes that are not yet full for this team
    classes_needed(current_team.get_classes).each do |clss, count| # logic/players.rb
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
    classes_needed(current_team.get_classes).key? clss # logic/players.rb
  end

  def pick_medic_conflicting? nick, clss
    return false unless @signups[nick].include? "medic"

    needed = 0
    medics = get_classes["medic"].size - 1 # the current pick is a medic

    @teams.each { |team| needed += 1 unless team.signups.values.include? "medic" or @signups_all[team.captain].include? "medic" }
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
    @pick_order << player
    @signups.delete player

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

    server = Thread.new { start_server }

    update_captains
    print_teams # update_captains (indicates dependencies)
    create_match # update_captains

    server.join

    announce_server # start_server
    announce_teams # update_captains, start_server

    end_game
    list_players
  end

  def update_captains
    @teams.each do |team|
      team.signups[team.captain] = classes_needed(team.get_classes).keys.first
    end
  end

  def create_match
    match = Match.create time: Time.now

    @teams.each do |team|
      team.save # teams have not been saved up to this point just in case of !endgame
      match.teams << team

      # Create each player's statistics
      team.signups.each do |nick, clss|
        u = @auth[nick]
        team.users << u

        p = create_player_record u, match, team
        create_stat_record p, "captain" if nick == team.captain # captain gets counted twice
        create_stat_record p, clss
      end
    end

    # Now store the picking statistics.  This has to be separate
    # because we access the db directly, and we don't want transaction
    # deadlock.
    db = SQLite3::Database.new(const["database"]["database"])
    db.transaction do |db|
      # Add an unpicked record for everyone who added.
      @signups_all.each do |nick, classes|
        u = @auth[nick]
        classes.each do |clss|
          next if clss == "captain"
          @teams.collect { |team| team.captain }.each do |captain|
            db.execute("insert into picks (captain, user, class, match, picked, opponent_picked, pick_order) values (?, ?, (select id from tfclasses where name = ?), ?, ?, ?, NULL)",
                       @auth[captain].id, u.id, clss, match.id, 0, 0)
          end
        end
      end
      # Now go back and update the records of those who were picked
      # (using ON CONFLICT REPLACE on PK).
      @teams.each do |team|
        team.signups.each do |nick, clss|
          u = @auth[nick]

          other_captains = @teams.collect { |team| team.captain }.reject { |captain| captain == team.captain }
          db.execute("insert into picks (captain, user, class, match, picked, opponent_picked, pick_order) values (?, ?, (select id from tfclasses where name = ?), ?, ?, ?, ?)",
                     @auth[team.captain].id, u.id, clss, match.id, 1, 0, @pick_order.index(u.name))
          other_captains.each do |other_captain|
            db.execute("insert into picks (captain, user, class, match, picked, opponent_picked, pick_order) values (?, ?, (select id from tfclasses where name = ?), ?, ?, ?, ?)",
                       @auth[other_captain].id, u.id, clss, match.id, 0, 1, @pick_order.index(u.name))
          end
        end
      end
    end
  end

  def create_player_record user, match, team
    user.players.create(match: match, team: team)
  end

  def create_stat_record player, clss
    player.stats.create(tfclass: Tfclass.find_by_name(clss))
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
