module Impressbox
  module Objects
    # This class is used for deal with configs subfolder contents
    class ConfigData

      # List all possible config of type
      #
      #@param name [String] Type name
      #
      #@return [Array]
      def self.list_of_type(name)
        ret = []
        Dir.entries(real_path(name)).select do |f|
          next if File.directory?(f)
          ret.push File.basename(f, '.*')
        end
        ret
      end

      # Appends configs path for supplied filename
      #
      #@param filename [String] Filename without path
      #
      #@return [String]
      def self.real_path(filename)
        File.join File.dirname(File.dirname(__FILE__)), 'configs', filename
      end

      # Makes fullname with suplied wilename
      #
      #@param type      [String]  Config type
      #@param filename  [String]  Filename without path and extension
      #
      #@return [String]
      def self.real_type_filename(type, filename)
        real_path File.join(type, filename + '.yml')
      end

      # Initializer
      #
      #@param filename [String] What config file to load
      def initialize(filename)
        @filename = ConfigData.real_path(filename)
        @data = symbolize_keys(load_yaml)
      end

      # Gets item from config data
      #
      #@param key [String] Key to get item by it's name
      #
      #@return [Object]
      def [](key)
        @data[key]
      end

      # Gets all config data
      #
      #@return [Hash]
      def all
        @data
      end

      private

      # Loads related YAML file
      #
      #@return [Object]
      def load_yaml
        YAML.load(File.open(@filename))
      end

      # Makes string to symbol if it was string
      #
      #@param key [String] Key to symbolize if needed
      #
      #@return [Symbol]
      def symbolize_make_new_key(key)
        case key
          when String then
            key.to_sym
          else
            key
        end
      end

      # Makes keys to symbols
      #
      # Code from http://devblog.avdi.org/2009/07/14/recursively-symbolize-keys/
      #
      #@param hash [Hash] Keys hash
      #
      #@return [Hash]
      def symbolize_keys(hash)
        hash.inject({}) do |result, (key, value)|
          new_key = symbolize_make_new_key(key)
          new_value = case value
                        when Hash then
                          symbolize_keys(value)
                        else
                          value
                      end
          result[new_key] = new_value
          result
        end
      end
    end
  end
end
