module Impressbox
  module Objects
    # Main code
    class Main < Impressbox::Objects::Base
      # Configuration
      @config = nil

      # Info
      @info = nil

      # Keys
      @keys = nil

      # Initializer
      def initialize(vagrant)
        @config = Impressbox::Objects::Config.read
        @info = Impressbox::Vagrant::Info.new
        @plugins = Impressbox::Vagrant::Plugins.new vagrant
        @keys = Impressbox::Objects::SSHkeyDetect.detect(@config)
        configure
      end

      def configure
        Vagrant.configure(@info.api_version) do |cfg|
          configurator = Impressbox::Configurator.new(cfg)
          use_configurator configurator
        end
      end

      def use_configurator(configurator)
        name = 'ImpressCMS/DevBox-Ubuntu'
        configurator.name name
        configurator.configure_network @config['ip']
        configurator.configure_ssh @keys.private
        configurator.forward_vars ['APP_ENV']
        configurator.check_for_update Cval.bool(@config, 'check_update', false)
        configurator.specific_configure @info.provider, @config
        _forward_ports configurator
        _basic_configure configurator, name
      end

      def _basic_configure(configurator, name)
        configurator.basic_configure Cval.str(@config, 'name', name),
                                     Cval.int(@config, 'cpus', 1),
                                     Cval.int(@config, 'memory', 512),
                                     Cval.bool(@config, 'gui', false)
      end

      def _forward_ports(configurator)
        if @config.key?('ports') && !@config.empty?
          configurator.forward_ports @config['ports']
        else
          error 'At least one port should be defined in config.yaml.'
        end
      end

      private :use_configurator,
              :configure,
              :_forward_ports
    end
  end
end
