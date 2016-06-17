# Loads all requirements
require 'vagrant'

module Impressbox
  # This class is used as dummy provisioner because all
  # provision tasks are now defined in actions
  class Provisioner < Vagrant.plugin('2', :provisioner)

    @@__loaded_config = nil

    # Object with loaded config from file
    def self.loaded_config
      @@__loaded_config
    end

    # Cleanup script
    def cleanup
    end

    # Configure
    def configure(root_config)
      @@__loaded_config = xaml_config(root_config)
      old_root = root_config.dup
      old_loaded = @@__loaded_config.dup
      mass_loader('primary').each do |configurator|
        next unless configurator.can_be_configured?(old_root, old_loaded)
        @machine.ui.info configurator.description if configurator.description
        configurator.configure root_config, old_loaded
      end
    end

    # Provision tasks
    def provision
      mass_loader('provision').each do |configurator|
        next unless configurator.can_be_configured?(@machine, @@__loaded_config)
        configurator.configure @machine, @@__loaded_config
      end
    end

    private

    def mass_loader(type)
      namespace = 'Impressbox::Configurators::' + ucfirst(type)
      path = File.join('..', 'configurators', type)
      Impressbox::Objects::MassFileLoader.new namespace, path
    end

    def ucfirst(str)
      str[0] = str[0, 1].upcase
      str
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
