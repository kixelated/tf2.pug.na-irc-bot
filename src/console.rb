require 'bundler/setup'
require_relative 'constants'

class Console
  include Constants
  
  def initialize
    yield
  end
  
  def message msg
    puts msg
  end
end
