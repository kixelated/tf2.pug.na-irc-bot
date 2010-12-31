require_relative 'logic/server'
require_relative 'constants'

class STVWrapper
  include ServerLogic
  include Constants
  
  def message msg
    puts msg
  end
end

stv = STVWrapper.new

stv.update_stv
stv.list_stv
