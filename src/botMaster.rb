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
      
      c.auth = Constants.const["irc"]["auth"]
      c.auth_password = Constants.const["irc"]["auth_password"]
      c.auth_serv = Constants.const["irc"]["auth_serv"]
      
      c.plugins.plugins = [ Pug, Quitter ]
      c.verbose = false
    end
    
    on :connect do 
      bot.msg Constants.const["irc"]["auth_serv"], "AUTH #{ Constants.const["irc"]["auth"] } #{ Constants.const["irc"]["auth_password"] }" if Constants.const["irc"]["auth"]
      bot.join Constants.const["irc"]["channel"]
    end

    BotManager.instance.add self
    BotManager.instance.logger = logger
  end
end

