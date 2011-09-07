require_relative '../model/team'
require_relative '../model/match'
require_relative '../model/player'
require_relative '../model/pick'
require_relative '../model/user'

module PickingRandomLogic
  def start_picking
    @teams = Array.new

    const["teams"]["count"].times do |i|
      team = Team.new
      team.signups = Hash.new
      team.set_details const["teams"]["details"][i]

      @teams << team
    end

    const["teams"]["classes"].each do |clss, count|
      (const["teams"]["count"] * count).times do
        classes = get_classes[clss]
        nick = classes[rand(classes.length)]
        pick_player nick, clss
      end
    end

    final_pick
  end

  def pick_player nick, clss
    current_team.signups[nick] = clss
    @signups.delete nick

    @pick += 1
  end

  def final_pick
    end_picking

    server = Thread.new { find_server }

    print_teams
    create_match

    server.join

    announce_server
    announce_teams

    list_players
    end_game
  end

  # I hate this function
  def create_match
    match = Match.create(:time => Time.now)
    
    team_lookup = {}
    @teams.each do |team|
      team.save # teams have not been saved up to this point just in case of !endgame
      match.teams << team
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
