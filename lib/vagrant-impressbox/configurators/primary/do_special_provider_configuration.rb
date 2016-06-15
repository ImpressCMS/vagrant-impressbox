module Impressbox
  module Configurators
    module Primary
      # Adds some extra configuration options based on provider
      class DoSpecialProviderConfiguration < Impressbox::Configurators::AbstractPrimary
        def description
          I18n.t 'configuring.provider'
        end

        def configure(vagrant_config, config_file)
          load_configurators detect_provider

          basic_configure vagrant_config, config_file
          specific_configure vagrant_config, config_file
        end

        private

        # Basic configure
        def basic_configure(vagrant_config, config_file)
          @configurators.each do |configurator|
            configurator.basic_configure vagrant_config,
                                         config_file.vmname,
                                         config_file.cpus,
                                         config_file.memory,
                                         config_file.gui
          end
        end

        # Specific configure
        def specific_configure(vagrant_config, config)
          @configurators.each do |configurator|
            configurator.specific_configure vagrant_config, config
          end
        end

        def detect_provider
          if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
            return (ARGV[1].split('=')[1] || ARGV[2])
          end
          (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
        end

        def load_configurators(provider)
          @configurators = []
          namespace = 'Impressbox::Configurators::ProviderSpecific'
          path = File.join('..', 'configurators', 'provider_specific')
          loader = Impressbox::Objects::MassFileLoader.new(namespace, path)
          loader.each do |instance|
            @configurators.push instance if instance.same?(provider)
          end
        end
      end
    end
  end
end
