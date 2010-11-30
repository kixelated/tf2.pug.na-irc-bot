module StateLogic
  # attempt_afk -> start_afk || attempt_picking
  # start_afk -> attempt_picking (delay)
  # attempt_picking -> start_delay, start_picking
  # start_delay -> nil
  # start_picking -> nil
  
  def attempt_afk
    if waiting? and minimum_players?
      @state = 1
      
      @afk = check_afk @afk # may take a while
      return start_afk unless @afk.empty?
      
      attempt_picking true
    end
  end
  
  def attempt_picking override = false
    # override is called if no players are afk as to avoid a redundant check
    if override or minimum_players?
      start_delay # pause for x seconds
      start_picking
    else
      @state = 0
    end
  end
  
  def check_afk list
    list.reject do |user|
      user.refresh
      !user.unknown? and p.idle <= Constants::afk_threshold # user is found and not idle
    end
  end

  def start_afk
    message "The following players are considered afk: #{ @afk.join(", ") }"
    
    @afk.each do |p|
      message p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants::afk_delay } seconds to avoid being removed."
    end
    
    sleep Constants::afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each_key { |k| @players.delete k }
    @afk.clear

    list_players
    attempt_picking 
  end
  
  def start_delay
    @state = 2
    
    message "Teams are being drafted, captains will be selected in #{ Constants::picking_delay } seconds"
    sleep Constants::picking_delay
  end
  
  def start_picking
    @state = 3
    
    choose_captains
    tell_captain
  end
  
  def end_picking
    start_game
    message "Game started. Add to the pug using the !add command."
  end
  
  def waiting?
    @state == 0
  end

  def picking? 
    @state == 3
  end

  def can_add?
    !picking?
  end
  
  def can_remove?
    !picking?
  end
end