require 'singleton'
require 'thread'

class MasterMessenger
  include Singleton
  
  def initialize
    @bots = []
    @log = []
    @queue = Queue.new
  end
  
  def add bot
    @bots << bot unless @bots.include? bot
  end
  
  def select
    @bots.push(@bots.shift).first 
  end
  
  def queuemsg channel, msg
    addqueue "msg", channel, msg
  end
  
  def queuenotice channel, msg
    addqueue "notice", channel, msg
  end

  
  def processqueue!
    while true
    
      mps            = Variables::Messenger_count  # 1 message per bot per second
      max_queue_size = Variables::Messenger_count * 5 # 5 consecutive lines per bot before putting in a throttle

      if @log.size > 1
        time_passed = 0

        @log.each_with_index do |one, index|
          second = @log[index+1]
          time_passed += second - one
          break if index == @log.size - 2
        end

        messages_processed = (time_passed * mps).floor
        effective_size = @log.size - messages_processed

        if effective_size <= 0
          @log.clear
        elsif effective_size >= max_queue_size
          sleep 1.0/mps
        else
          sleep 0.1
        end
      end
 
      message = @queue.pop
      
      @log << Time.now
      @time_since_last_send = Time.now

      send(message[:type], message[:channel], message[:msg])
    end
  end
  
  private
  
  def addqueue type, channel, msg
    var = {}
    var[:type] = type
    var[:channel] = channel
    var[:msg] = msg
    @queue << var
  end

  def msg channel, msg
    select.msg channel, msg
  end
  
  def notice channel, msg
    select.notice channel, msg
  end
  
end