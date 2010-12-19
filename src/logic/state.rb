module StateLogic
  def attempt_afk
    if @state == const["states"]["waiting"] and minimum_players?
      @state = const["states"]["afk"]
      
      @afk = check_afk @signups.keys
      start_afk unless @afk.empty?
      
      attempt_picking
    end
  end
  
  def attempt_picking
    unless start_delay and start_picking 
      @state = const["states"]["waiting"]
    end
  end
  
  def check_afk list
    list.select do |user|
      !@spoken[user] or (Time.now - @spoken[user]).to_i > const["settings"]["afk"]
    end
  end

  def start_afk
    message "#{ colourize rjust("AFK players:"), const["colours"]["yellow"] } #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ const["delays"]["afk"] } seconds to avoid being removed."
    end
    
    sleep const["delays"]["afk"]

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |user| @signups.delete user }
    @afk.clear

    list_players # playersLogic.rb
  end
  
  def start_delay
    if minimum_players?
      @state = const["states"]["delay"]
      
      message colourize "Teams are being drafted, captains will be selected in #{ const["delays"]["picking"] } seconds", const["colours"]["yellow"]
      sleep const["delays"]["picking"]
      
      true
    end
  end
  
  def start_picking
    if minimum_players?
      @state = const["states"]["picking"]
      
      update_lookup # pickingLogic.rb
      choose_captains # pickingLogic.rb
      tell_captain # pickingLogic.rb
      
      true
    end
  end
  
  def end_picking
    @state = const["states"]["server"]
  end
  
  def end_game
    @teams.clear
    @captains.clear
    @lookup.clear

    @last = Time.now
    @state = const["states"]["waiting"]
    @pick = 0
    
    @authnames.reject! { |k, v| !@signups.key? k }
    @spoken.reject! { |k, v| !@signups.key? k }

    next_server
    next_map
  end
  
  def reset_game
    setup
  end
  
  def list_afk
    message "#{ rjust "AFK players:" } #{ check_afk(@signups.keys).join(", ") }"
  end
  
  def picking? 
    @state == const["states"]["picking"]
  end

  def can_add?
    @state < const["states"]["picking"]
  end
  
  def can_remove?
    @state < const["states"]["picking"]
  end
end
