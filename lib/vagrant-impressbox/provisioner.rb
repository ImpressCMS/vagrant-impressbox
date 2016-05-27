# Loads all requirements
require 'vagrant'

module Impressbox
  # This class is used as dummy provisioner because all
  # provision tasks are now defined in actions
  class Provisioner < Vagrant.plugin('2', :provisioner)
    # Cleanup script
    def cleanup
    end

    # Configure
    def configure(root_config)
      config = xaml_config(root_config)
      Impressbox::Objects::MassFileLoader.new(
        'Impressbox::Configurators::Default',
        File.join('..', 'configurators', 'default')
      ).each do |configurator|
        next unless configurator.can_be_configured?(root_config, config)
        configurator.configure root_config, config
      end
    end

    private

    # load xaml config
    def xaml_config(root_config)
      require_relative File.join('..', 'objects', 'config_file')
      file = detect_file(root_config)
      @ui.info "\t" + I18n.t('config.loaded_from_file', file: file)
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
