module Impressbox
  module Configurators
    module Primary
      # Adds some extra configuration options based on extension
      class DoExtensionConfiguration < Impressbox::Abstract::ConfiguratorPrimary

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.extension', {extension: @extension}
        end

        # Can be extension configured?
        #
        #@param vagrant_config [Object]                            Current Vagrant config
        #@param file_config    [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return [Boolean]
        def can_be_configured?(vagrant_config, file_config)
          !vagrant_config.impressbox.extension.nil? && !vagrant_config.impressbox.extension.empty?
        end

        # Do configuration tasks
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(vagrant_config, config_file)
          @extension = vagrant_config.impressbox.extension
          instance = create_instance(@extension)
          instance.configure vagrant_config, config_file
        end

        private

        # Creates instance of extension
        #
        #@param name [String] Extension name
        #
        #@return [::Impressbox::Abstract::Extension]
        def create_instance(name)
          ::Impressbox::Objects::Extensions.create_instance name
        end

      end
    end
  end
end
