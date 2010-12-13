require 'cinch'

require './constants.rb'
require './botManager.rb'
require './pug.rb'
require './quitter.rb'

class BotMaster < Cinch::Bot
  include Constants

  def initialize
    super

    @server = const["irc"]["server"]
    @port = const["irc"]["port"]
    @vhost = const["irc"]["local_host"]
    @nick = const["irc"]["nick"]
    @channels = [ const["irc"]["channel"] ]
    
    @plugins = [ Pug, Quitter ]
    @verbose = true
    
    BotManager.instance.add self
  end
end

