require_relative 'base_action'

module Impressbox
  module Actions
    # Configures provision script
    class ConfigureProvision < BaseAction
      private

      def description
        I18n.t 'configuring.provision'
      end

      def can_be_configured?(config)
        p = config.provision
        false unless p.is_a?(String)
        p.strip!
        !p.empty?
      end

      def configure(machine, config)
        machine.config.vm.provision 'shell' do |s|
          s.inline = config.provision
          s.keep_color = true
          s.binary = true
        end
      end
    end
  end
end
