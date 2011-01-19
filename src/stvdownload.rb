require_relative 'console'
require_relative 'logic/server'

class DownloadSTV < Console
  include ServerLogic
end

stv = DownloadSTV.new
stv.update_stv
stv.list_stv
