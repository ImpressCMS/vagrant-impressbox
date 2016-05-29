# Loads all requirements
require 'vagrant'

module Impressbox
  # This class is used as dummy provisioner because all
  # provision tasks are now defined in actions
  class Provisioner < Vagrant.plugin('2', :provisioner)
    # Object with loaded config from file
    attr_accessor :loaded_config

    # Cleanup script
    def cleanup
    end

    # Configure
    def configure(root_config)
      @loaded_config = xaml_config(root_config)
      mass_loader('default').each do |configurator|
        next unless configurator.can_be_configured?(root_config, @loaded_config)
        configurator.configure root_config, @loaded_config
      end
    end

    # Provision tasks
    def provision
      mass_loader('provision').each do |configurator|
        next unless configurator.can_be_configured?(@machine, @loaded_config)
        configurator.configure @machine, @loaded_config
      end
    end

    private

    def mass_loader(type)
      namespace = 'Impressbox::Configurators::' + type
      path = File.join('..', 'configurators', type)
      Impressbox::Objects::MassFileLoader.new namespace, path
    end

    # load xaml config
    def xaml_config(root_config)
      require_relative File.join('objects', 'config_file')
      file = detect_file(root_config)
      @machine.ui.info "\t" + I18n.t('config.loaded_from_file', file: file)
      Impressbox::Objects::ConfigFile.new file
    end

    def detect_file(root_config)
      file = if good_file_in_config?(root_config.impressbox)
               root_config.impressbox.file
             else
               'config.yaml'
             end
      file
    end

    def good_file_in_config?(impressbox)
      return false if impressbox.nil?
      impressbox.file.is_a?(String)
    end
  end
end
