module PlayersLogic
  def add_player user, classes
    remove_player user
    
    @players[user] = []
    classes.each do |c|
      @players[user] << c if @team_classes.key? c and !@players[user].include? c 
    end
  
    @players.delete user if @players[user].empty?
    @players.key? user
  end

  def remove_player user
    (@players.delete user) != nil
  end

  def list_players
    msg "#{@players.length} users added: #{@players.keys.collect { |x| x.nick }}"
  end

  def list_players_detailed
    Util::hash_invert_a(@players).each do |k, v|
      msg "#{k}: #{v.collect { |x| x.nick }}"
    end
  end
  
  def minimum_players?
    return false if @players.length < @team_size * 2
    Util::hash_invert_a(@players).each do |k, v|
      return false if v.length < @team_classes[k] * 2
    end
    
    true
  end
end