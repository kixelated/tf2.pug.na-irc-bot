require_relative 'constants'
require_relative 'botMaster'
require_relative 'botMessenger'

BotMaster.new.start

#Thread.new do
#  BotMaster.new.start
#end

Constants.const["messengers"]["count"].times do |i|
  sleep(10)

  Thread.new do
    BotMessenger.new(i).start
  end
end

BotManager.instance.start
