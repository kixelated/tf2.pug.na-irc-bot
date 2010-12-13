require 'cinch'

require './variables.rb'
require './botManager.rb'
require './pug.rb'
require './quitter.rb'

class BotMaster < Cinch::Bot
  def initialize
    super
    
    configure do |c|
      c.server = Const::Irc_server
      c.port = Const::Irc_port
      c.vhost = Const::Irc_vhost
      c.nick = Const::Nick_bot
      c.channels = [ Const::Irc_channel ]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = true
    end
    
    BotManager.instance.add self
  end
end

