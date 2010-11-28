module PlayersLogic
  def add_player user, cs
    @players[user] = []
    invalid = []
    
    cs.each do |c|
      if @classes_count.key? c
        @players[user] << c unless @players[user].include? c
      else 
        invalid << c
      end
    end
    
    priv user, "Invalid classes: #{ invalid }" unless invalid.empty?
    
    @players.delete user if @players[user].empty?
    @players.key? user
  end

  def remove_player user
    (@players.delete user) != nil
  end
  
  def list_players
    msg "#{ @players.length } users added: [#{ @players.keys.join(", ") }]"
  end

  def list_players_detailed
    @players.invert_arr.each do |k, v|
      msg "#{ k.capitalize }: [#{ v.join(", ") }]"
    end
  end

  def minimum_players?
    # false if the total number of players is not enough
    return false if @players.size < @team_size * @team_count
    
    # false if any of the classes do not meet the requirements
    @players.invert_arr.each do |k, v|
      return false if v.size < @classes_count[k] * @team_count
    end
    
    true
  end
end