require './server.rb'
require './serverLogic.rb'
require './variables.rb'

class ServerTest
  include ServerLogic
  include Variables
  
  def initialize
    setup
  end
  
  def message msg
    puts msg
  end
end

test = ServerTest.new
test.list_server
test.start_server