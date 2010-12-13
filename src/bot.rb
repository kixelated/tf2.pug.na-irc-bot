require './botManager.rb'
require './botMaster.rb'
require './botMessenger.rb'

mainbot = Thread.new do
  BotMaster.new.start
end

Const::Messenger_count.times do |i|
  sleep(10)

  Thread.new do
    BotMessenger.new(i).start
  end
end

mainbot.join