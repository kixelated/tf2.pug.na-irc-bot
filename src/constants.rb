require 'yaml'

module Constants
  @@const = YAML.load_file '../cfg/constants.yml'

  def const
    @@const
  end
end