require 'cinch'

require './constants.rb'
require './botManager.rb'
require './pug.rb'
require './quitter.rb'

class BotMaster < Cinch::Bot
  include Constants

  def initialize
    super
    
    configure do |c|
      c.server = Constants.const["irc"]["server"]
      c.port = Constants.const["irc"]["port"]
      c.vhost = Constants.const["irc"]["local_host"]
      c.nick = Constants.const["irc"]["nick"]
      c.channels = [ Constants.const["irc"]["channel"] ]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = true
    end

    BotManager.instance.add self
  end
end

