# Loads all requirements
require 'vagrant'

module Impressbox
  # This class is used as dummy provisioner because all
  # provision tasks are now defined in actions
  class Provisioner < Vagrant.plugin('2', :provisioner)

    # Stores loaded ConfigFile instance
    #
    #@return [::Impressbox::Objects::ConfigFile,nil]
    @@__loaded_config = nil

    # Object with loaded config from file
    #
    #@return [::Impressbox::Objects::ConfigFile,nil]
    def self.loaded_config
      @@__loaded_config
    end

    # Cleanup operations
    def cleanup
    end

    # Do configuration operations
    #
    #@param root_config [Object]  Current Vagrantfile configuration instance
    def configure(root_config)
      @@__loaded_config = xaml_config
      run_primaty_configuration root_config
    end

    # Do provision tasks
    def provision
      mass_loader('provision').each do |configurator|
        next unless configurator.can_be_configured?(@machine, @@__loaded_config)
        configurator.configure @machine, @@__loaded_config
      end
    end

    private

    # Runs primary configuration
    #
    #@param root_config [Object] Root Vagrant config
    def run_primaty_configuration(root_config)
      old_root = root_config.dup
      old_loaded = @@__loaded_config.dup
      mass_loader('primary').each do |configurator|
        next unless configurator.can_be_configured?(old_root, old_loaded)
        @machine.ui.info configurator.description if configurator.description
        configurator.configure root_config, old_loaded
      end
    end

    # Gets preconfigured MassFileLoader instance
    #
    #@param type [String] Files type
    #
    #@return [::Impressbox::Objects::MassFileLoader]
    def mass_loader(type)
      namespace = 'Impressbox::Configurators::' + ucfirst(type)
      path = File.join('..', 'configurators', type)
      Impressbox::Objects::MassFileLoader.new namespace, path
    end

    # Makes first latter of tsuplied world in uppercase
    #
    #@param str [String]  String to do what needed to do
    #
    #@return [String]
    def ucfirst(str)
      str[0] = str[0, 1].upcase
      str
    end

    # Loads xaml config
    #
    #@return [::Impressbox::Objects::ConfigFile]
    def xaml_config
      require_relative File.join('objects', 'config_file')
      file = detect_file(config.file)
      @machine.ui.info "\t" + I18n.t('config.loaded_from_file', file: file)
      Impressbox::Objects::ConfigFile.new file
    end

    # Try to detect config.yaml file
    #
    #@param file [String]  Tries file and if not returns default file
    #
    #@return [String]
    def detect_file(file)
      return file if good_file_in_config?(file)
      'config.yaml'
    end

    # Is a good config.yaml file specifed in Vagrantfile ?
    #
    #@param impressbox [Object] Vagrantfile configuration part with impressbox
    #
    #@return [Boolean]
    def good_file_in_config?(impressbox)
      return false if impressbox.nil?
      impressbox.file.is_a?(String)
    end
  end
end
