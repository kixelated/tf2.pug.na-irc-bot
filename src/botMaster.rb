require 'cinch'

require_relative 'constants'
require_relative 'botManager'
require_relative 'pug'
require_relative 'quitter'

class BotMaster < Cinch::Bot
  include Constants

  def initialize
    super
    
    configure do |c|
      c.server = Constants.const["irc"]["server"]
      c.port = Constants.const["irc"]["port"]
      c.local_host = Constants.const["irc"]["local_host"]
      c.nick = Constants.const["irc"]["nick"]
      c.channels = [ Constants.const["irc"]["channel"] ]
      
      c.auth = Constants.const["irc"]["auth"]
      c.auth_password = Constants.const["irc"]["auth_password"]
      c.auth_serv = Constants.const["irc"]["auth_serv"]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = true
    end

    BotManager.instance.add self
  end
end

