require 'cinch'

require_relative 'constants'
require_relative 'botManager'
require_relative 'pug'
require_relative 'cup'

class BotMaster < Cinch::Bot
  include Constants

  def initialize
    super
    
    configure do |c|
      c.server = Constants.const["irc"]["server"]
      c.port = Constants.const["irc"]["port"]
      c.nick = Constants.const["irc"]["nick"]
      c.local_host = Constants.const["internet"]["local_host"]
      
      c.channels = [ Constants.const["irc"]["channel"] ]
      c.plugins.plugins = [ Pug, Cup ]

      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.const["irc"]["auth_serv"], "AUTH #{ Constants.const["irc"]["auth"] } #{ Constants.const["irc"]["auth_password"] }" if Constants.const["irc"]["auth"]
    end

    BotManager.instance.add self
  end
end

