require './constants.rb'

require './botMaster.rb'
require './botMessenger.rb'

Thread.new do
  BotMaster.new.start
end

Constants.const["messengers"]["count"].times do |i|
  sleep(10)

  Thread.new do
    BotMessenger.new(i).start
  end
end

BotManager.instance.start
