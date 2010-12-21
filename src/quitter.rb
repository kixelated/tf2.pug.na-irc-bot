require 'cinch'
require_relative 'botManager'

class Quitter
  include Cinch::Plugin

  match /quit/, method: :quit
  
  def quit m
    BotManager.instance.quit if m.channel.opped? m.user
  end
end
