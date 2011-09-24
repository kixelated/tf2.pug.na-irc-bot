require 'yaml'

module Const
  def const
    @const
  end

  def load_config
    @const = YAML.load_file(File.dirname(__FILE__) + '/../cfg/constants.yml')
  end

  def calculate
    const["teams"]["count"] = const["teams"]["details"].size
    const["teams"]["total"] = const["teams"]["players"] * const["teams"]["count"]
  end
end

class GlobalConstants
  include Const
end

Constants = GlobalConstants.new
Constants.load_config
Constants.calculate
