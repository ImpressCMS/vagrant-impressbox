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

      # @!attribute [rw] ip
      attr_accessor :ip

      # @!attribute [rw] hostname
      attr_accessor :hostname

      # @!attribute [rw] name
      attr_accessor :name

      # @!attribute [rw] cpus
      attr_accessor :cpus

      # @!attribute [rw] memory
      attr_accessor :memory

      # @!attribute [rw] check_update
      attr_accessor :check_update

      # @!attribute [rw] keys
      attr_accessor :keys

      # @!attribute [rw] smb
      attr_accessor :smb

      # @!attribute [rw] ports
      attr_accessor :ports

      # @!attribute [rw] gui
      attr_accessor :gui

      # @!attribute [rw] vars
      attr_accessor :vars

      # @!attribute [rw] provision
      attr_accessor :provision

      def initialize(file)
        @default = ConfigData.new('default.yml')
        map_values YAML.load(File.open(file))
      end

      private

      def map_values(config)
        %w(
          cpus memory check_update ip hostname name
          ports keys smb provision).each do |attr|
          method_name = 'convert_' + attr
          instance_variable_set '@' + attr, method(method_name).call(config)
        end
      end

      def convert_provision(config)
        select_value(config, 'provision', @default[:provision]).to_s
      end

      def convert_name(config)
        select_value(config, 'name', @default[:name]).to_s
      end

      def convert_ip(config)
        select_value(config, 'ip', @default[:ip])
      end

      def convert_cpus(config)
        select_value(config, 'cpus', @default[:cpus]).to_s.to_i
      end

      def convert_memory(config)
        select_value(config, 'memory', @default[:memory]).to_s.to_i
      end

      def convert_hostname(config)
        value = select_value(config, 'hostname', @default[:hostname])
        return @default[:hostname] if value.nil?
        unless value.is_a?(String) && value.is_a?(Array)
          return @default[:hostname]
        end
        value
      end

      def convert_ports(config)
        select_value(config, 'ports', @default[:ports])
      end

      def convert_check_update(config)
        value = select_value(config, 'check_update', @default[:check_update])
        to_b(value)
      end

      def to_b(value)
        return true if value
        false
      end

      def convert_keys(config)
        value = select_value(config, 'keys', {})
        value = {} unless value.is_a?(Hash)
        value[:private] = nil unless value.key?('private')
        value[:public] = nil unless value.key?('public')
        value
      end

      def convert_smb(config)
        value = select_value(config, 'smb', {})
        value = {} unless value.is_a?(Hash)
        value[:ip] = nil unless value.key?('ip')
        value[:user] = nil unless value.key?('user')
        value[:pass] = nil unless value.key?('pass')
        value
      end

      def select_value(config, key, default_value)
        return config[key] if config.key?(key)
        default_value
      end
    end
  end
end
