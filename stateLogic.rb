module StateLogic
  def attempt_afk
    if @state == Const::State_waiting and minimum_players?
      @state = Const::State_afk
      
      @afk = check_afk @players.keys
      start_afk unless @afk.empty?
      
      attempt_picking
    end
  end
  
  def attempt_picking
    unless start_delay and start_picking 
      @state = Const::State_waiting
    end
  end
  
  def check_afk list
    list.select do |user|
      !@spoken[user] or (Time.now - @spoken[user]).to_i > Const::Afk_threshold
    end
  end

  def start_afk
    message "#{ colourize rjust("AFK players:"), Const::Colour_yellow } #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Const::Afk_delay } seconds to avoid being removed."
    end
    
    sleep Const::Afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |user| @players.delete user }
    @afk.clear

    list_players # playersLogic.rb
  end
  
  def start_delay
    if minimum_players?
      @state = Const::State_delay
      
      message colourize "Teams are being drafted, captains will be selected in #{ Const::Picking_delay } seconds", Const::Colour_yellow
      sleep Const::Picking_delay
      
      true
    end
  end
  
  def start_picking
    if minimum_players?
      @state = Const::State_picking
      @players.rehash # just in case, as add/remove is no officially closed
      
      update_lookup # pickingLogic.rb
      choose_captains # pickingLogic.rb
      tell_captain # pickingLogic.rb
      
      true
    end
  end
  
  def end_picking
    start_server # serverLogic.rb
    announce_teams # pickingLogic.rb
    announce_server # serverLogic.rb
    end_game
  end
  
  def end_game
    @teams.clear
    @captains.clear
    @lookup.clear

    @last = Time.now
    @state = Const::State_waiting
    @pick = 0
    
    @spoken.reject! { |k, v| !@players.key? k }

    next_server
    next_map
  end
  
  def reset_game
    setup
  end
  
  def list_afk
    message "#{ rjust "AFK players:" } #{ check_afk(@players.keys).join(", ") }"
  end
  
  def picking? 
    @state == Const::State_picking
  end

  def can_add?
    @state < Const::State_picking
  end
  
  def can_remove?
    @state < Const::State_picking
  end
end