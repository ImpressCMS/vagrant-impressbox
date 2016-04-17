# Loads all requirements
require 'vagrant'
require_relative File.join('objects', 'ssh_key_detect.rb')

# Impressbox namepsace
module Impressbox
  # Provisioner namepsace
  class Provisioner < Vagrant.plugin('2', :provisioner)
    # @!attribute [rw] provision_actions
    attr_accessor :provision_actions

    def provision
      if !@provision_actions.nil? && @provision_actions.to_s.length > 0
        @machine.communicate.wait_for_ready 300

        @machine.communicate.execute(@provision_actions.to_s) do |type, line|
          write_line type, line
        end
      end
    end

    def cleanup
    end

    def configure(root_config)
      configurator = create_configurator(root_config)
      cfg = xaml_config

      do_primary_configuration configurator, cfg
      do_ssh_configuration configurator, cfg
      do_provider_configuration configurator, cfg
      do_network_configuration configurator, cfg
      do_exec_configure configurator, cfg
      do_provision_configure configurator, cfg
    end

    private

    def write_line(type, contents)
      case type
      when :stdout
        @machine.ui.info contents
      when :stderr
        @machine.ui.error contents
      else
        @machine.ui.info 'W: ' + type
        @machine.ui.info contents
      end
    end

    def do_provision_configure(_configurator, cfg)
      @provision_actions = cfg.provision if !cfg.provision.nil? && cfg.provision
    end

    def do_primary_configuration(configurator, cfg)
      configurator.name cfg.name
      configurator.check_for_update cfg.check_update
      configurator.forward_ports cfg.ports
    end

    def do_exec_configure(configurator, cfg)
      configurator.configure_exec cfg.cmd unless cfg.cmd.nil?
    end

    def do_network_configuration(configurator, cfg)
      configurator.configure_network cfg.ip unless cfg.ip.nil?
    end

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
      require_relative File.join('objects', 'config_file')
      Impressbox::Objects::ConfigFile.new @config.file
    end
  end
end
