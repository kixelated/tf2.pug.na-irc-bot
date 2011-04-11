require 'cinch'

require_relative 'constants'
require_relative 'util'

class Cup
  include Cinch::Plugin
  
  include Constants
  include Utilities

  match /cup(?: (.+))?$/i, method: :command_cup
  match /cuplist$/i, method: :command_cuplist
  
  timer 60, method: :dump_cup

  def initialize(*args)
    super
    
    @cup = {}
    @cup_changed = false
    
    if File.exists?('cup.txt')
      File.open('cup.txt').each_line do |str|
        if str =~ /^(\w+): (.+)$/
          @cup[$1] = $2.split(/ /)
        end
      end
    end
  end

  def command_cup m, classes
    unless classes
      notice(m.user, "You have been removed from the cup.") if @cup.delete(m.user.nick)
      message("#{ @cup.size } users signed up for the cup.")
    else
      classes = classes.split(/ /)
      classes.collect! { |clss| clss.downcase } # convert classes to lowercase
      classes.uniq! # remove duplicate classes

      rej = classes.reject! { |clss| not const["teams"]["classes"].key? clss } # remove invalid classes
      return notice m.user, "Invalid classes. Possible options are #{ const["teams"]["classes"].keys * ", " }" if rej
      
      @cup[m.user.nick] = classes
      @cup_changed = true
      
      notice(m.user, "Thanks for signing up for the cup! Teams will be chosen at a later date and posted.")
      message("#{ @cup.size } users signed up for the cup.")
    end
  end
  
  def command_cuplist m
    message("#{ @cup.keys * ", " }") if m.channel.opped?(m.user)
  end
  
  def dump_cup
    if @cup_changed
      @cup_changed = false
      File.open('cup.txt', 'w') do |f| 
        @cup.each do |nick, classes|
          f.write("#{ nick }: #{ classes * " " }\n")
        end
      end
    end
  end
  
  def message msg
    BotManager.instance.msg const["irc"]["channel"], colourize(msg.to_s)
    false
  end
  
  def private user, msg
    BotManager.instance.msg user, msg
    false
  end

  def notice channel = const["irc"]["channel"], msg
    BotManager.instance.notice channel, msg
    false
  end
end
