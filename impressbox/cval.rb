module Impressbox
  # Config values parsing
  class Cval
    # Parses bool value
    def self.bool(config, name, default = nil)
      return default unless config.key?(name)
      return true if config[name]
      false
    end

    # Parses string value
    def self.str(config, name, default = nil)
      return config[name].to_s if config.key?(name)
      default
    end

    # Parses Int value
    def self.int(config, name, default = nil)
      return config[name].to_s.to_i if config.key?(name)
      default
    end

    # Parses Enum value
    def self.enum(config, name, default, possible)
      value = str(config, name, default)
      return value if possible.include?(value)
      default
    end
  end
end
