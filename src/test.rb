require_relative 'logic/server'
require_relative 'variables'

class Console
  include ServerLogic
  include Variables
 
  def message msg
    puts msg
  end
end

console = Console.new
console.setup
console.list_status
