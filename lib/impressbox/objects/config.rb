require 'vagrant'
require 'yaml'

# Impressbox namespace
module Impressbox
  # Objects namepsace
  module Objects
    # Config reader
    class Config
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
      
      # @!attribute [rw] cmd
      attr_accessor :cmd             

      def initialize(file)
        config = YAML.load(File.open(file))
        @cpus = convert_cpus(config)
        @memory = convert_memory(config)
        @check_update = convert_check_update(config)
        @ip = convert_ip(config)
        @hostname = convert_hostname(config)
        @name = convert_name(config)
        @ports = convert_ports(config)
        @keys = convert_key(config)
        @smb = convert_smb_value(config)
        @cmd = convert_cmd(config)
      end

      private

      def convert_cmd(config)
        select_value(config, 'cmd', 'php /vagrant/www/cmd.php').to_s
      end
      
      def convert_name(config)
        select_value(config, 'name', @hostname).to_s
      end

      def convert_ip(config)
        select_value(config, 'ip', UNSET_VALUE)
      end

      def convert_cpus(config)
        select_value(config, 'cpus', 1).to_s.to_i
      end

      def convert_memory(config)
        select_value(config, 'memory', 512).to_s.to_i
      end

      def convert_hostname(config)
        select_value(config, 'hostname', 'impressbox.dev').to_s
      end

      def convert_ports(config)
        select_value(config, 'ports', [])
      end

      def convert_check_update(config)
        value = select_value(config, 'check_update', false)
        to_b(value)
      end

      def to_b(value)
        return true if value
        false
      end

      def convert_key(config)
        value = select_value(config, 'keys', {})
        value = {} unless value.is_a?(Hash)
        value[:private] = nil unless value.key?('private')
        value[:public] = nil unless value.key?('public')
        value
      end

      def convert_smb_value(config)
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
