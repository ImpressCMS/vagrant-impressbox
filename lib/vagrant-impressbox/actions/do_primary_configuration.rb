require_relative 'base_action'

module Impressbox
  module Actions
    # Configures hostnames (with HostManager plug-in)
    class DoPrimaryConfiguration < BaseAction
      private

      def description
        I18n.t 'configuring.primary'
      end

      def configure(data)
        default_configure data[:vagrantfile], data[:config]

        forward_ports data[:vagrantfile], data[:config].ports
      end

      def default_configure(vagrantfile, config)
        vagrantfile.vm.box = config.name
        vagrantfile.vm.box_check_update = config.check_update
      end

      # forward one port
      def forward_port(vagrantfile, guest_port, host_port, protocol = 'tcp')
        vagrantfile.vm.network 'forwarded_port',
                                  guest: guest_port,
                                  host: host_port,
                                  protocol: protocol,
                                  auto_correct: true
      end

      # Forward ports
      def forward_ports(vagrantfile, ports)
        return if ports.nil?
        ports.each do |pgroup|
          forward_port vagrantfile,
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
