require_relative '../constants'
require_relative 'botMaster'
require_relative 'botMessenger'
require_relative 'botManager'

def start_bots!
  main = Thread.new do
    BotMaster.new.start
  end

  #main.join

  Constants.messengers['count'].times do |i|
    sleep(5)

    Thread.new do
      BotMessenger.new(i).start
    end
  end

  sleep(5)

  BotManager.instance.start
end
