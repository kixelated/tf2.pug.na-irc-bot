require 'bundler/setup'

require_relative 'constants'
require_relative 'botMaster'
require_relative 'botMessenger'

main = Thread.new do
  BotMaster.new.start
end

# for debugging
#main.join

Constants.const["messengers"]["count"].times do |i|
  sleep(5)

  Thread.new do
    BotMessenger.new(i).start
  end
end

sleep(5)

BotManager.instance.start
