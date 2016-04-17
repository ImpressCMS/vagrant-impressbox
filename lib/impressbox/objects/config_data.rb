module Impressbox
  module Objects
    # This class is used for deal with configs subfolder contents
    class ConfigData      
      def self.list_of_type(name)
        ret = []
        Dir.entries(self.real_path(name)).select do |f|
          next if File.directory?(f)
          ret.push File.basename(f, '.*')
        end
        ret
      end

      def self.real_path(filename)
        File.join File.dirname(File.dirname(__FILE__)), 'configs', filename
      end

      def self.real_type_filename(type, filename)
        self.real_path File.join(type, filename + '.yml')
      end

      def initialize(filename)
        @filename = ConfigData.real_path(filename)
        @data = symbolize_keys(load_yaml)
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

      def symbolize_make_new_key(key)
        case key
        when String then key.to_sym
        else key
        end
      end

      # Code from http://devblog.avdi.org/2009/07/14/recursively-symbolize-keys/
      def symbolize_keys(hash)
        hash.inject({}) do |result, (key, value)|
          new_key = symbolize_make_new_key(key)
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
