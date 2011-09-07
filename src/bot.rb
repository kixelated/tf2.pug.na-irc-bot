require 'bundler/setup'

require_relative 'constants'
require_relative 'botMaster'
require_relative 'botMessenger'

bots = Array.new
2.times do |i|
  bots << Thread.new do
    BotMaster.new(i).start
  end

  sleep(5)
end

# for debugging
#main.join

Constants.const["messengers"]["count"].times do |i|
  Thread.new do
    BotMessenger.new(i).start
  end

  sleep(5)
end

BotManager.instance.start
