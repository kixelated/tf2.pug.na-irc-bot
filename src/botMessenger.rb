require 'cinch'
require_relative 'constants'
require_relative 'botManager'

class BotMessenger < Cinch::Bot
  include Constants

  def initialize i
    super()
    
    configure do |c|
      c.server = Constants.const["irc"]["server"]
      c.port = Constants.const["irc"]["port"]
      c.nick = Constants.const["messengers"]["nick"] + i.to_s
      c.local_host = Constants.const["internet"]["local_host"]
      
      c.channels = [ Constants.const["irc"]["channel"] ] 
      
      c.encoding = :irc
      c.verbose = false
    end
    
    BotManager.instance.add self
  end
end

