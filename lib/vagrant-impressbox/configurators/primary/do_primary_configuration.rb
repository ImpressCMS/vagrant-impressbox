module Impressbox
  module Configurators
    module Primary
      # Configures hostnames (with HostManager plug-in)
      class DoPrimaryConfiguration < Impressbox::Abstract::ConfiguratorPrimary

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.primary'
        end

        # Do configuration tasks
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(vagrant_config, config_file)
          default_configure vagrant_config, config_file

          forward_ports vagrant_config, config_file.ports
        end

        private

        # Do default configuration
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param config          [::Impressbox::Objects::ConfigFile] Loaded config file data
        def default_configure(vagrantfile, config)
          if config.name
            vagrantfile.vm.define config.name.to_s
          end
          vagrantfile.vm.box_check_update = config.check_update
        end

        # Forwards one port
        #
        #@param vagrantfile [Object]  Current vagrant config
        #@param guest_port  [Integer] Port on guest machine
        #@param host_port   [Integer] Port on host machine
        #@param protocol    [String]  TCP or UDP
        def forward_port(vagrantfile, guest_port, host_port, protocol = 'tcp')
          vagrantfile.vm.network 'forwarded_port',
                                 guest: guest_port,
                                 host: host_port,
                                 protocol: protocol,
                                 auto_correct: true
        end

        # Forward ports from hash
        #
        #@param vagrantfile [Object]  Current vagrant config
        #@param ports       [Array]   Array with forwarding data
        def forward_ports(vagrantfile, ports)
          return if ports.nil?
          ports.each do |pgroup|
            forward_port vagrantfile,
                         pgroup['guest'],
                         pgroup['host'],
                         extract_protocol(pgroup)
          end
        end

        # Extracts protocol name from array port item
        #
        #@param pgroup [Hash] Ports array item
        #
        #@return [String]
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
