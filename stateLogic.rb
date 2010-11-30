module StateLogic
  def can_add?
    !picking?
  end
  
  def picking? 
    @state == 3
  end
  
  # attempt_afk -> start_afk || attempt_picking
  # start_afk -> attempt_picking (delay)
  # attempt_picking -> start_delay, start_picking
  # start_delay -> nil
  # start_picking -> nil
  
  def attempt_afk
    if @state == 0 and minimum_players?
      @players.each_key do |p|
        p.refresh
        @afk << p if p.idle > @afk_threshold
      end
      
      if @afk.empty?
        attempt_picking true
      else
        start_afk 
      end
    end
  end
  
  def attempt_picking override = false
    @afk = []
  
    if override or minimum_players?
      start_delay
      start_picking
    else
      @state = 0
    end
  end

  def start_afk
    @state = 1
    msg "The following players are considered afk: [#{ @afk.join(", ") }]"
    
    sleep(@afk_delay)

    @afk.each do |p|
      p.refresh
      @players.delete p if p.idle > @afk_threshold
    end

    list_players
    attempt_picking 
  end
  
  def start_delay
    @state = 2
    
    msg "Teams are being drafted, captains will be selected in #{@picking_delay} seconds"
    sleep(@picking_delay)
  end
  
  def start_picking
    @state = 3
    
    choose_captains
  end
  
  def end_picking
    start_game
  end
end