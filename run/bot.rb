require 'bundler/setup'

require_relative '../src/database'
require_relative '../src/constants'
require_relative '../src/bot/master'
require_relative '../src/bot/messenger'
require_relative '../src/bot/manager'

DataMapper.finalize

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
