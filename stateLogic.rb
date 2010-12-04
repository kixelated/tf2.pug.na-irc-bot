module StateLogic
  def attempt_afk
    if @state == Variables::State_waiting and minimum_players?
      @state = Variables::State_afk
      
      @afk = check_afk @players.keys
      start_afk unless @afk.empty?
      
      attempt_picking
    end
  end
  
  def attempt_picking
    if minimum_players?
      start_delay # pause for x seconds
      start_picking
    else
      @state = Variables::State_waiting
    end
  end
  
  def check_afk list
    list.reject do |user|
      user.refresh
      !user.unknown? and user.idle <= Variables::Afk_threshold # user is found and not idle
    end
  end

  def start_afk
    message "The following players are considered afk: #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Variables::Afk_delay } seconds to avoid being removed."
    end
    
    sleep Variables::Afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |user| @players.delete user }
    @afk.clear

    list_players # playersLogic.rb
  end
  
  def start_delay
    @state = Variables::State_delay
    
    message "Teams are being drafted, captains will be selected in #{ Variables::Picking_delay } seconds"
    sleep Variables::Picking_delay
  end
  
  def start_picking
    @state = Variables::State_picking
    
    update_lookup # pickingLogic.rb
    choose_captains # pickingLogic.rb
    tell_captain # pickingLogic.rb
  end
  
  def end_game
    @teams.clear
    @lookup.clear

    @state = Variables::State_waiting
    @pick = 0
    
    next_server
    next_map
    
    message "Game started. Add to the pug using the !add command."
  end
  
  def picking? 
    @state == Variables::State_picking
  end

  def can_add?
    @state < Variables::State_picking
  end
  
  def can_remove?
    @state < Variables::State_picking
  end
end