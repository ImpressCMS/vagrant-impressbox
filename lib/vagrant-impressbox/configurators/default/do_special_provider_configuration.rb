module Impressbox
  module Configurators
    module Default
      # Adds some extra configuration options based on provider
      class DoSpecialProviderConfiguration < Impressbox::Configurators::Default
        CONFIGURATORS = %w(
          HyperV
          VirtualBox
        ).freeze

        def description
          I18n.t 'configuring.provider'
        end

        def configure(_vagrant_config, config_file)
          load_configurators detect_provider

          config = config_file
          basic_configure config.name, config.cpus, config.memory, config.gui
          specific_configure config
        end

        private

        # Basic configure
        def basic_configure(vmname, cpus, memory, gui)
          @configurators.each do |configurator|
            configurator.basic_configure vmname, cpus, memory, gui
          end
        end

        # Specific configure
        def specific_configure(config)
          @configurators.each do |configurator|
            configurator.specific_configure config
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
          CONFIGURATORS.each do |name|
            require_relative File.join('..', 'configurators', name.downcase)
            class_name = 'Impressbox::Configurators::' + name
            clazz = class_name.split('::').inject(Object) do |o, c|
              o.const_get c
            end
            instance = clazz.new(@config)
            @configurators.push instance if instance.same?(provider)
          end
        end
      end
    end
  end
end
