require 'vagrant'
require 'yaml'
require_relative 'config_data'

# Impressbox namespace
module Impressbox
  # Objects namepsace
  module Objects
    # Config reader
    class ConfigFile
      UNSET_VALUE = ::Vagrant::Plugin::V2::Config::UNSET_VALUE

      attr_reader :vars
      attr_reader :smb
      attr_reader :keys
      attr_reader :ports
      attr_reader :check_update
      attr_reader :cpus
      attr_reader :memory
      attr_reader :gui
      attr_reader :provision
      attr_reader :name
      attr_reader :ip
      attr_reader :hostname

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

      def vars=(value)
        @vars = qq_array(value, 'vars')
      end

      def smb=(value)
        @smb = qq_hash(value, 'smb', ['ip', 'user', 'pass'])
      end

      def keys=(value)
        @keys = qq_hash(value, 'keys', ['private', 'public'])
      end

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

      def check_update=(value)
        @check_update = qg_bool(value, 'check_update')
      end

      def cpus=(value)
        @cpus = qg_int(value, 'cpus')
      end

      def memory=(value)
        @memory = qg_int(value, 'memory')
      end

      def gui=(value)
        @gui = qg_bool(value, 'gui')
      end

      def provision=(value)
        @provision = qg_str_or_nil(value, 'provision')
      end

      def name=(value)
        @name = qg_str_not_empty(value, 'name')
      end

      def ip=(value)
        @ip = qg_str_or_nil(value, 'ip')
      end

      def hostname=(value)
        @hostname = qg_str_array(value, 'hostname')
      end

      private

      attr_reader :_default

      def load_yaml(file)
        YAML.load(File.open(file))
      end

      def default_yaml
        File.join __dir__, '..', 'configs', 'default.yml'
      end

      def qq_hash(value, default_value_key, keys)
        if hash_with_keys?(value, keys)
          return value
        end
        @_default[default_value_key]
      end

      def qq_array(value, default_value_key)
        return value if value.is_a?(Array)
        @_default[default_value_key]
      end

      def qg_int(value, default_value_key)
        return value if value.is_a?(Integer)
        return value.to_i if non_zero_int?(value)
        @_default[default_value_key]
      end

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

      def qg_str_not_empty(value, default_value_key)
        return if value.kind_of?(String) && !value.empty?
        @_default[default_value_key]
      end

      def qg_str_or_nil(value, default_value_key)
        return value if value.nil? or value.kind_of?(String)
        @_default[default_value_key]
      end

      def qg_str_array(value, default_value_key)
        return [value] if value.kind_of?(String)
        return value if value.kind_of?(Array)
        @_default[default_value_key]
      end

      def hash_with_keys?(value, keys)
        return false unless value.kind_of?(Hash)
        keys.each do |key|
          return false unless value.key?(key)
        end
        true
      end

      def non_zero_int?(value)
        value.to_s.to_i == value.to_i
      end

    end
  end
end
