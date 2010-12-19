module StateLogic
  def attempt_afk
    if state? "waiting" and minimum_players?
      start_afk
      attempt_delay
    end
  end
  
  def check_afk list
    list.select do |user|
      !@spoken[user] or (Time.now - @spoken[user]).to_i > const["settings"]["afk"]
    end
  end
  
  def start_afk
    state "afk"
  
    @afk = check_afk @signups.keys
    return if @afk.empty?
  
    message "#{ colourize rjust("AFK players:"), const["colours"]["yellow"] } #{ @afk.join(", ") }"
    
    @afk.each do |p|
      private p, "Warning, you are considered afk by the bot. Say anything in the channel within the next #{ const["delays"]["afk"] } seconds to avoid being removed."
    end
    
    sleep const["delays"]["afk"]
    
    # return if not needed
    return unless @state == const["states"]["afk"]

    # check again if users are afk, this time removing the ones who are
    check_afk(@afk).each { |user| @signups.delete user }
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
        start_picking
      else
        state "waiting"
      end
    end
  end
  
  def start_picking
    state "picking"
    
    update_lookup # logic/picking.rb
    choose_captains # logic/picking.rb
    tell_captain # logic/picking.rb
  end
  
  def end_picking
    state "server"
  end
  
  def end_game
    @teams.clear
    @lookup.clear

    @last = Time.now
    state "waiting"
    @pick = 0
    
    @auth.reject! { |k, v| !@signups.key? k }
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
