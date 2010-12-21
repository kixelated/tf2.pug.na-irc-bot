require 'singleton'
require_relative 'constants'

class BotManager
  include Singleton
  include Constants
  
  def initialize
    @bots = []
    @queue = Queue.new
    @quit = false
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def quit
    @bots.each { |bot| bot.quit }
    @quit = true
  end
  
  def select
    @bots.push(@bots.shift).first
  end
  
  def msg(to, message)
    @queue << { :type => "msg", :to => to, :message => message }
  end
  
  def notice(to, message)
    @queue << { :type => "notice", :to => to, :message => message }
  end
  
  def start
    while not @quit
      unless @queue.empty?
        m = @queue.pop
        
        if m.type == "msg"
          select.msg m.to, m.message
        else 
          select.notice m.to, m.message
        end
        
        sleep 1.0 / const["messengers"]["mpstotal"]
      end
    end
  end
end
