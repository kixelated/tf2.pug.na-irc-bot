require 'yaml'

module Constants
  def self.const
    @@const
  end
  
  def const
    @@const
  end
  
  def self.load_config
    @@const = YAML.load_file '../cfg/constants.yml'
  end
  
  def self.calculate
    const["teams"]["count"] = const["teams"]["details"].size
    const["teams"]["total"] = const["teams"]["players"] * const["teams"]["count"]
  end
end

Constants.load_config
Constants.calculate
