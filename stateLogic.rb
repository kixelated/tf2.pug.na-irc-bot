module StateLogic
  # attempt_afk -> start_afk || attempt_picking
  # start_afk -> attempt_picking (delay)
  # attempt_picking -> start_delay, start_picking
  # start_delay -> nil
  # start_picking -> nil
  
  def attempt_afk
    if @state == Variables::State_waiting and minimum_players?
      @state = Variables::State_afk
      
      @afk = check_afk @afk # may take a while
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
      !user.unknown? and p.idle <= Variables::Afk_threshold # user is found and not idle
    end
  end

  def start_afk
    message "The following players are considered afk: #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Variables::Afk_delay } seconds to avoid being removed."
    end
    
    sleep Variables::Afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each_key { |k| @players.delete k }
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
  
  def end_picking
    @teams.clear
    @lookup.clear

    @state = Variables::State_waiting
    @pick = 0
    
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