require_relative 'base_action'

module Impressbox
  module Actions
    # Configures hostnames (with HostManager plug-in)
    class DoPrimaryConfiguration < BaseAction

      private

      def description
        I18n.t 'configuring.primary'
      end

      def configure(machine, config)
        machine.config.vm.box = config.name
        machine.config.vm.box_check_update = config.check_update

        forward_ports machine.config, config.ports
      end

      # forward one port
      def forward_port(machine_config, guest_port, host_port, protocol = 'tcp')
        machine_config.vm.network 'forwarded_port',
                                  guest: guest_port,
                                  host: host_port,
                                  protocol: protocol,
                                  auto_correct: true
      end

      # Forward ports
      def forward_ports(machine_config, ports)
        return if ports.nil?
        ports.each do |pgroup|
          forward_port machine_config,
                       pgroup['guest'],
                       pgroup['host'],
                       extract_protocol(pgroup)
        end
      end

      def extract_protocol(pgroup)
        possible = %w(tcp udp)
        return 'tcp' unless pgroup.key?('protocol')
        return 'tcp' unless possible.include?(pgroup['protocol'])
        pgroup[protocol]
      end

    end
  end
end
