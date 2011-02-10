require 'bundler/setup'

require_relative 'variables'
require_relative 'logic/server'
require_relative 'util'

class Console
  include Utilities
  include Variables
  include ServerLogic
  
  def message msg
    puts msg
  end
end

console = Console.new

console.setup
console.list_status

20.times do |i|
  console.find_server
  console.announce_server
  console.next_server
  console.next_map

  puts "Sleeping for #{ 2**i } seconds."
  sleep 2**i
end
