# Loads all requirements
require 'vagrant'
require_relative File.join('objects', 'ssh_key_detect.rb')

# Impressbox namepsace
module Impressbox
  # Provisioner namepsace
  class Provisioner < Vagrant.plugin('2', :provisioner)
    def provision
      # require 'vagrant-hostmanager'
    end

    def cleanup
    end

    def configure(root_config)
      configurator = create_configurator(root_config)
      cfg = xaml_config

      configurator.name cfg.name
      configurator.check_for_update cfg.check_update
      configurator.forward_ports cfg.ports
      configurator.configure_network cfg.ip unless cfg.ip.nil?
      configurator.configure_exec cfg.cmd unless cfg.cmd.nil?

      do_ssh_configuration configurator, root_config
      do_provider_configuration configurator, cfg
    end

    private

    def do_ssh_configuration(configurator, cfg)
      keys = Impressbox::Objects::SshKeyDetect.new(cfg)
      configurator.configure_ssh keys.public_key, keys.private_key
    end

    def do_provider_configuration(configurator, cfg)
      configurator.basic_configure cfg.name, cfg.cpus, cfg.memory, cfg.gui
      configurator.specific_configure cfg
    end

    def detect_provider
      if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
        return (ARGV[1].split('=')[1] || ARGV[2])
      end
      (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
    end

    def create_configurator(root_config)
      require_relative File.join('objects', 'configurator')
      Impressbox::Objects::Configurator.new(
        root_config,
        @machine,
        detect_provider
      )
    end

    def xaml_config
      require_relative File.join('objects', 'config')
      Impressbox::Objects::Config.new @config.file
    end
  end
end
