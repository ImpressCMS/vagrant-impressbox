module Impressbox
  module Objects
    # This class is used for deal with configs subfolder contents
    class ConfigData
      def initialize(filename)
        @filename = File.join(path, filename)
        @data = symbolize_keys(load_yaml)
      end

      attr_reader :filename

      def path
        File.join File.dirname(File.dirname(__FILE__)), 'configs'
      end

      def [](key)
        @data[key]
      end

      def all
        @data
      end

      private

      def load_yaml
        YAML.load(File.open(@filename))
      end

      # Code from http://devblog.avdi.org/2009/07/14/recursively-symbolize-keys/
      def symbolize_keys(hash)
        hash.inject({}) do |result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then symbolize_keys(value)
                      else value
                      end
          result[new_key] = new_value
          result
        end
      end
    end
  end
end
