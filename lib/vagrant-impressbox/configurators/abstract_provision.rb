# Impressbox namespace
module Impressbox
  module Configurators
    # Base class used for provision tasks
    class AbstractProvision
      # Configure machine on provision
      #
      #@param machine         [::Vagrant::Machine]                Current machine
      #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
      def configure(machine, config_file)
        raise I18n.t('configuring.error.must_overwrite')
      end

      # This method is used for description
      #
      #@return [String]
      def description
      end

      # Can be executed ?
      #
      #@param machine     [::Vagrant::Machine]                Current machine
      #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
      #
      #@return            [Boolean]
      def can_be_configured?(machine, config_file)
        true
      end
    end
  end
end
