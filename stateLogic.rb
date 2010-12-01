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
      start_afk unless @afk.empty?
      
      attempt_picking
    end
  end
  
  def attempt_picking
    if minimum_players?
      start_delay # pause for x seconds
      start_picking
    else
      @state = 0
    end
  end
  
  def check_afk list
    list.reject do |user|
      user.refresh
      !user.unknown? and p.idle <= Constants::Afk_threshold # user is found and not idle
    end
  end

  def start_afk
    message "The following players are considered afk: #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ Constants::Afk_delay } seconds to avoid being removed."
    end
    
    sleep Constants::Afk_delay

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each_key { |k| @players.delete k }
    @afk.clear

    list_players
  end
  
  def start_delay
    @state = 2
    
    message "Teams are being drafted, captains will be selected in #{ Constants::Picking_delay } seconds"
    sleep Constants::Picking_delay
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