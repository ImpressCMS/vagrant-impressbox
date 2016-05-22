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
        false unless p.kind_of?(String)
        p.strip!
        !p.empty?
      end

      def configure(machine, config)
        @ui.info config.provision.inspect
        machine.config.vm.provision "shell" do |s|
          s.inline = config.provision
          s.keep_color = true
          s.binary = true
        end
      end

    end
  end
end
