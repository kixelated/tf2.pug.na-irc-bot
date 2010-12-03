require './lib/messagebot.rb'
require 'thread'


class Messenger
  include Cinch::Plugin
  
  messagequeue = Queue.new 
  arr = []
  
  def initialize
    Messenger_count.times do |i|
      arr[i] = Thread.new {
        IrcMessenger.new("irc.gamesurge.net", 6667, "TF2PUGMESS" + i.to_s, "#tf2.pug.na.beta", messagequeue)
        sleep(6)
      }
    end
    arr.each {|t| t.join}
  end
  
  
  def say arg
    messagequeue << arg
  end
  
  

  
end