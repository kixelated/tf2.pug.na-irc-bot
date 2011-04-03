require 'cinch'

require 'tf2pug'
require 'tf2pug/constants'

class BotMaster < Cinch::Bot
  def initialize
    super
    
    configure do |c|
      c.server = Constants.irc['server']
      c.port = Constants.irc['port']
      c.nick = Constants.irc['nick']
      c.local_host = Constants.internet['local_host']
      
      c.channels = [ Constants.irc['channel'] ]
      c.plugins.plugins = [ Pug ]

      c.verbose = false
    end
    
    on(:connect) do 
      bot.msg(Constants.irc['auth_serv'], "AUTH #{ Constants.irc['auth'] } #{ Constants.irc['auth_password'] }") if Constants.irc['auth']
    end
  end
end
