require 'bundler/setup'

require_relative 'logic/server'

class Console
  include ServerLogic
  
  def message msg
    puts msg
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!

console = Console.new
console.list_status

4.times do |i|
  map = console.find_map
  server = console.find_server map
  
  console.announce_server server, map

  puts "Sleeping for #{ 2**i } seconds."
  sleep 2**i
end
