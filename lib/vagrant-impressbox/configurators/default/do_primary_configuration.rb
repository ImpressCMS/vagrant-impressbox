module Impressbox
  module Configurators
    module Default
      # Configures hostnames (with HostManager plug-in)
      class DoPrimaryConfiguration < Impressbox::Configurators::Default
        def description
          I18n.t 'configuring.primary'
        end

        def configure(vagrant_config, config_file)
          default_configure vagrant_config, config_file

          forward_ports vagrant_config, config_file.ports
        end

        def default_configure(vagrantfile, config)
          vagrantfile.vm.box = config.name
          vagrantfile.vm.box_check_update = config.check_update
        end

        private

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
end
