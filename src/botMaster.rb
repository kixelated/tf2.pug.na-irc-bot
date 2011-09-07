require 'cinch'

require_relative 'constants'
require_relative 'botManager'
require_relative 'pug'
require_relative 'pug-random'

class BotMaster < Cinch::Bot
  include Constants

  def initialize(i)
    super()
    
    # ugly but fast
    case i
    when 0
      plugin = Pug
      nick = Constants.const["irc"]["nick"]
      channel = Constants.const["irc"]["channel"]
    when 1
      plugin = PugRandom
      nick = Constants.const["irc"]["nick2"]
      channel = Constants.const["irc"]["channel2"]
    end

    configure do |c|
      c.server = Constants.const["irc"]["server"]
      c.port = Constants.const["irc"]["port"]
      c.nick = nick
      c.local_host = Constants.const["internet"]["local_host"]

      c.channels = [ channel ]
      c.plugins.plugins = [ plugin ]

      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.const["irc"]["auth_serv"], "AUTH #{ Constants.const["irc"]["auth"] } #{ Constants.const["irc"]["auth_password"] }" if Constants.const["irc"]["auth"]
    end

    BotManager.instance.add self, channel
  end
end

