require_relative 'base_action'

module Impressbox
  module Actions
    # Configures network
    class ConfigureNetwork < BaseAction
      private

      def description
        I18n.t 'configuring.network'
      end

      def can_be_configured?(config)
        !config.ip.nil? && config.ip
      end

      def configure(machine, config)
        machine.config.vm.network 'private_network',
                                  ip: config.ip
      end
    end
  end
end
