include './constants.rb'

module Variables
  def setup
    @channel = "#tf2.pug.na.beta"
    
    @servers = [ Constants::Chicago1 ]
    @maps = [ "cp_badlands", "cp_granary" ]
  
    @players = {}
    @afk = []

    @teams = []
    @lookup = {}

    @state = Constants::State_waiting
    @pick = 0
  end
end
