require 'singleton'

require './constants.rb'

class BotManager
  include Singleton
  include Constants
  
  def initialize
    @bots = []
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def quit
    @bots.reject! { |bot| bot.quit }
  end
  
  def select
    @bots.push(@bots.shift).first
  end

  def msg channel, msg
    select.msg channel, msg
    sleep const["delays"]["message"]
  end
  
  def notice channel, msg
    select.notice channel, msg
    sleep const["delays"]["message"]
  end
end