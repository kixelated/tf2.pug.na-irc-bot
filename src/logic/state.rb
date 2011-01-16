module StateLogic
  def update_spoken user
    @spoken[user.nick] = Time.now
    
    if @afk.delete user.nick and @afk.empty?
      attempt_delay # logic/state.rb
    end
  end

  def attempt_afk
    if state? "waiting" and minimum_players?
      start_afk
      attempt_delay
    end
  end
  
  def check_afk list
    list.select do |nick|
      !@spoken[nick] or (Time.now - @spoken[nick]).to_i > const["settings"]["afk"]
    end
  end
  
  def start_afk
    state "afk"
  
    @afk = check_afk @signups.keys
    return if @afk.empty?
  
    message "#{ colourize rjust("AFK players:"), const["colours"]["yellow"] } #{ @afk * ", " }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ const["delays"]["afk"] } seconds to avoid being removed."
    end
    
    sleep const["delays"]["afk"]
    
    # return if not needed
    return unless @state == const["states"]["afk"]

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |nick| @signups.delete nick }
    @afk.clear

    list_players # logic/players.rb
  end
  
  def attempt_delay
    if state? "afk"
      if minimum_players?
        start_delay
        attempt_picking
      else 
        state "waiting"
      end
    end
  end
  
  def start_delay
    state "delay"
        
    message colourize "Teams are being drafted, captains will be selected in #{ const["delays"]["picking"] } seconds", const["colours"]["yellow"]
    sleep const["delays"]["picking"]
  end
  
  def attempt_picking
    if state? "delay"
      if minimum_players? 
        state "picking"
        start_picking
      else
        state "waiting"
      end
    end
  end

  def end_picking
    state "server"
  end 
  
  def reset_game
    setup
  end
  
  def list_afk
    message "#{ rjust "AFK players:" } #{ check_afk(@signups.keys) * ", " }"
  end

  def state s
    @state = const["states"][s]
  end

  def state? s
    @state == const["states"][s]
  end

  def can_add?
    @state < const["states"]["picking"]
  end
  
  def can_remove?
    @state < const["states"]["picking"]
  end
end
