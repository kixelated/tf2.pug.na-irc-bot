require 'yaml'

module Constants
  def self.method_missing(sym, *args, &block)
    return @@const[sym.to_s] if @@const.key? sym.to_s
    super
  end

  def self.load_config
    @@const = YAML.load_file '../cfg/constants.yml'
  end
end

Constants.load_config
