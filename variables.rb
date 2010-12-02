module Variables
  Afk_threshold = 60 * 5
  Afk_delay = 45
  Server_delay = 60
  Picking_delay = 45

  Team_count = 2
  Team_names = [ "Red team", "Blue team" ]
  Team_colours = [ 4, 10 ]
  
  Chicago1 = Server.new("chicago1.tf2pug.org", 27015, "tf2pug", "squid")
  
  Server_used = 8
  
  State_waiting = 0
  State_afk = 1
  State_delay = 2
  State_picking = 3
  State_server = 4

  def setup
    @channel = "#tf2.pug.na.beta"
    
    @servers = [ Variables::Chicago1 ]
    @maps = [ "cp_badlands", "cp_coldfront", "cp_gullywash_imp3", "cp_freight_final1", "cp_granary", "koth_viaduct" ]
  
    @players = {}
    @afk = []

    @teams = []
    @lookup = {}

    @state = Variables::State_waiting
    @pick = 0
  end
end