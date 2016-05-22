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

      def configure(data)
          data[:vagrantfile].vm.provision "impressbox_shell", type: "shell" do |s|
            s.inline = data[:config].provision
          end
      end
    end
  end
end
