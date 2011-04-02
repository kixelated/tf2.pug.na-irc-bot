require 'yaml'

module Constants
  # Provides a way to do "Constants.database" rather than "Constants.const['database']"
  def self.method_missing(sym, *args, &block)
    return @@const[sym.to_s] if @@const.key? sym.to_s
    super
  end

  def self.load_config
    @@const = YAML.load_file '../../cfg/constants.yml' # TODO: Path is wrong
  end
end

Constants.load_config
