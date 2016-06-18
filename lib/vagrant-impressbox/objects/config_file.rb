require 'vagrant'
require 'yaml'
require_relative 'config_data'

# Impressbox namespace
module Impressbox
  # Objects namepsace
  module Objects
    # Config reader
    class ConfigFile

      # Binds long constant name to short name
      #
      # Unset value is used for Vagrant to indetify when value was not set
      UNSET_VALUE = ::Vagrant::Plugin::V2::Config::UNSET_VALUE

      # Environment vars collection
      #
      #@!attribute [rw] vars
      #
      #@return [Hash]
      attr_reader :vars

      # Samba configuration
      #
      #@!attribute [rw] smb
      #
      #@return [Hash]
      attr_reader :smb

      # SSH keys filenames
      #
      #@!attribute [rw] keys
      #
      #@return [Hash]
      attr_reader :keys

      # Ports bidning between host and guest
      #
      #@!attribute [rw] ports
      #
      #@return [Array]
      attr_reader :ports

      # Check box for update?
      #
      #@!attribute [rw] check_update
      #
      #@return [Boolean]
      attr_reader :check_update

      # How many CPUs to use for box?
      #
      #@!attribute [rw] cpus
      #
      #@return [Integer]
      attr_reader :cpus

      # How much memory (in megabytes) to use for virtual box?
      #
      #@!attribute [rw] memory
      #
      #@return [Integer]
      attr_reader :memory

      # Show GUI?
      #
      #@!attribute [rw] gui
      #
      #@return [Boolean]
      attr_reader :gui

      # Defines shell provision commands
      #
      #@!attribute [rw] provision
      #
      #@return [String]
      attr_reader :provision

      # Box name
      #
      #@!attribute [rw] name
      #
      #@return [String]
      attr_reader :name

      # Binded IP
      #
      #@!attribute [rw] ip
      #
      #@return [Hash]
      attr_reader :ip

      # Binded hostname(s)
      #
      #@!attribute [rw] hostname
      #
      #@return [String,Array]
      attr_reader :hostname

      # Initializer
      #
      #@param file [String] Config filename
      # Load config from root
      def self.load_from_root_config(root_config)
        file = self.detect_file_in_root_config(root_config)
       # machine.ui.info "\t" + I18n.t('config.loaded_from_file', file: file)
        self.new file
      end

      # Detect file in
      def self.detect_file_in_root_config(root_config)
        if good_file_in_config?(root_config.impressbox)
          return root_config.impressbox.file
        end
        'config.yaml'
      end

      # Validates if that is a good file in config
      def self.good_file_in_config?(impressbox)
        return false if impressbox.nil?
        impressbox.file.is_a?(String)
      end

      # Constructor / Initializer
      def initialize(file)
        @_default = load_yaml(default_yaml)

        data = load_yaml(file)

        @_default.each do |key, value|
          if self.respond_to?(key + '=')
            send key + "=", data[key]
          end
        end
      end

      # Sets 'vars' variable
      #
      #@param value [Object]  Value to set to variable
      def vars=(value)
        @vars = qq_array(value, 'vars')
      end

      # Sets 'smb' variable
      #
      #@param value [Object]  Value to set to variable
      def smb=(value)
        @smb = qq_hash(value, 'smb', ['ip', 'user', 'pass'])
      end

      # Sets 'keys' variable
      #
      #@param value [Object]  Value to set to variable
      def keys=(value)
        @keys = qq_hash(value, 'keys', ['private', 'public'])
      end

      # Sets 'ports' variable
      #
      #@param value [Object]  Value to set to variable
      def ports=(value)
        if value.kind_of?(Array)
          @ports = value.select do |el|
            return false unless hash_with_keys?(el, ['host', 'guest'])
            non_zero_int?(el['guest']) && non_zero_int?(el['host'])
          end
        else
          @ports = @_default['ports']
        end
      end

      # Sets 'check_update' variable
      #
      #@param value [Object]  Value to set to variable
      def check_update=(value)
        @check_update = qg_bool(value, 'check_update')
      end

      # Sets 'cpus' variable
      #
      #@param value [Object]  Value to set to variable
      def cpus=(value)
        @cpus = qg_int(value, 'cpus')
      end

      # Sets 'memory' variable
      #
      #@param value [Object]  Value to set to variable
      def memory=(value)
        @memory = qg_int(value, 'memory')
      end

      # Sets 'gui' variable
      #
      #@param value [Object]  Value to set to variable
      def gui=(value)
        @gui = qg_bool(value, 'gui')
      end

      # Sets 'provision' variable
      #
      #@param value [Object]  Value to set to variable
      def provision=(value)
        @provision = qg_str_or_nil(value, 'provision')
      end

      # Sets 'name' variable
      #
      #@param value [Object]  Value to set to variable
      def name=(value)
        @name = qg_str_not_empty(value, 'name')
      end

      # Sets 'ip' variable
      #
      #@param value [Object]  Value to set to variable
      def ip=(value)
        @ip = qg_str_or_nil(value, 'ip')
      end

      # Sets 'hostname' variable
      #
      #@param value [Object]  Value to set to variable
      def hostname=(value)
        @hostname = qg_str_array(value, 'hostname')
      end

      private

      # Default values data (used when assigning variable)
      #
      #@!attribute [r] _default
      #@return [Hash]
      attr_reader :_default

      # Load Yaml file and returns contents
      #
      #@param file [String] File to load
      #
      #@return [Object]
      def load_yaml(file)
        YAML.load(File.open(file))
      end

      # Gets default config file
      #
      #@return [String]
      def default_yaml
        File.join __dir__, '..', 'configs', 'default.yml'
      end

      # Test if hash with specific keys and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #@param keys              [Array]   Keys list to check
      #
      #@return [Hash]
      def qq_hash(value, default_value_key, keys)
        if hash_with_keys?(value, keys)
          return value
        end
        @_default[default_value_key]
      end

      # Test if array and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [Array]
      def qq_array(value, default_value_key)
        return value if value.is_a?(Array)
        @_default[default_value_key]
      end

      # Test if integer and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [Integer]
      def qg_int(value, default_value_key)
        return value if value.is_a?(Integer)
        return value.to_i if non_zero_int?(value)
        @_default[default_value_key]
      end

      # Test if boolean and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [Boolean]
      def qg_bool(value, default_value_key)
        return value if (!!value) == value
        return @_default[default_value_key] unless value.kind_of?(String)
        case value.downcase
          when 'false', '0', 'no', '-', 'f', 'n', 'off'
            return false
          when 'true', '1', 'yes', '+', 't', 'y', 'on'
            return true
        end
        @_default[default_value_key]
      end

      # Test if string and not empty and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [String]
      def qg_str_not_empty(value, default_value_key)
        return if value.kind_of?(String) && !value.empty?
        @_default[default_value_key]
      end

      # Test if string or nil and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [String,nil]
      def qg_str_or_nil(value, default_value_key)
        return value if value.nil? or value.kind_of?(String)
        @_default[default_value_key]
      end

      # Test if array or string and if not returns one from default values
      #
      #@param value             [Object]  Value to test
      #@param default_value_key [String]  Key for default values hash
      #
      #@return [Array,String]
      def qg_str_array(value, default_value_key)
        return [value] if value.kind_of?(String)
        return value if value.kind_of?(Array)
        @_default[default_value_key]
      end

      # Is Hash with specific keys ?
      #
      #@param value [Object]  Object to test
      #@param keys  [Array]   Keys list
      #
      #@return [Boolean]
      def hash_with_keys?(value, keys)
        return false unless value.kind_of?(Hash)
        keys.each do |key|
          return false unless value.key?(key)
        end
        true
      end

      # Is non zero integer ?
      #
      #@param value [Object]  value to test
      #
      #@return [Boolean]
      def non_zero_int?(value)
        value.to_s.to_i == value.to_i
      end

    end
  end
end
