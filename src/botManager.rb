require 'singleton'
require_relative 'constants'

class BotManager
  include Singleton
  include Constants
  
  attr_accessor :logger
  
  def initialize
    @bots = []
    @queue = []
    
    @logger = nil
    @quit = false
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def quit
    @bots.each { |bot| bot.quit }
    @bots.clear
    @quit = true
  end

  def msg to, message, notice = false
    @queue << { :to => to, :message => message, :notice => notice }
    logger.log message, :outgoing
  end
  
  def notice to, message
    msg to, message, true
  end
  
  def start
    while not @quit
      unless @queue.empty? or @bots.size == 0
        tosend = @queue.shift
        bot = @bots.push(@bots.shift).last
        
        bot.msg tosend[:to], tosend[:message], tosend[:notice]
        
        sleep(1.0 / (const["messengers"]["mps"].to_f * @bots.size.to_f))
      else
        sleep(const["delays"]["manager"].to_f)
      end
    end
  end
end
