require_relative 'summer'
require_relative 'constants'
require_relative 'botManager'

class BotMessenger < Summer::Connection
  include Constants

  def initialize num = 0
    super(
      const["irc"]["server"], 
      const["irc"]["port"], 
      "#{ const["messengers"]["nick"] }#{ num }", 
      const["irc"]["nick"], 
      const["irc"]["local_host"], 
    )

    BotManager.instance.add self
  end
end

