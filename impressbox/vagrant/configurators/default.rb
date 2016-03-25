module Impressbox
  module Vagrant
    module Configurators
      # Default configurator
      class Default < Impressbox::Vagrant::Configurators::Base
        # Some providers configurators
        @configurators = []

        # initializtor
        def initialize(config)
          super config

          @configurators = [
            Impressbox::Vagrant::Configurators::HyperV.new(config),
            Impressbox::Vagrant::Configurators::VirtualBox.new(config)
          ]
        end

        # Provision
        # cd /srv/www/phpmyadmin
        # chown -R www-data ./
        # chgrp www-data ./
        # git pull
        # chown -R www-data ./
        # chgrp www-data ./
        # cd /srv/www/Memchaced-Dashboard
        # chown -R www-data ./
        # chgrp www-data ./
        # git pull
        # chown -R www-data ./
        # chgrp www-data ./
        def provision
          @config.vm.provision 'shell', inline: <<-SHELL
             sudo -u root bash -c 'cd /srv/www/impresscms && chown -R www-data ./ && chgrp www-data ./ &&  git pull && chown -R www-data ./ && chgrp www-data ./'
             if [ ![ -L "/srv/www/impresscms" && -d "/srv/www/impresscms" ] ]; then
               echo "ImpressCMS dir setup running..."
               sudo -u root bash -c 'rm -rf /vagrant/impresscms/'
               sudo -u root bash -c 'mv /srv/www/impresscms /vagrant/'
               sudo -u root bash -c 'ln -s /vagrant/impresscms /srv/www/impresscms'
             fi
          SHELL
        end

        # Basic configure
        def basic_configure(vmname, cpus, memory, gui)
          @configurators.each do |configurator|
            configurator.basic_configure vmname, cpus, memory, gui
          end
        end

        # Specific configure
        def specific_configure(provider, config)
          @configurators.each do |configurator|
            if configurator.same?(provider)
              configurator.specific_configure config
            end
          end
        end

        # Box name to use for this vagrant configuration
        def name(name)
          @config.vm.box = name
        end

        # Configure SSH
        def configure_ssh(private_key)
          @config.ssh.insert_key = true
          @config.ssh.pty = false
          @config.ssh.forward_x11 = false
          @config.ssh.forward_agent = false
          @config.ssh.private_key_path = File.dirname(private_key)
        end

        # Configure network
        def configure_network(ip)
          @config.vm.network 'private_network',
                             ip: ip
        end

        # Forward vars
        def forward_vars(vars)
          @config.ssh.forward_env = vars
        end

        # Automatically check for update for this box ?
        def check_for_update(check)
          @config.vm.box_check_update = check
        end

        # forward one port
        def forward_port(guest_port, host_port, protocol = 'tcp')
          @config.vm.network 'forwarded_port',
                             guest: guest_port,
                             host: host_port,
                             protocol: protocol,
                             auto_correct: true
        end

        # Forward ports
        def forward_ports(ports)
          ports.each do |pgroup|
            forward_port pgroup['guest'],
                         pgroup['host'],
                         Cval.enum(
                           pgroup,
                           'protocol',
                           'tcp',
                           %w(tcp udp)
                         )
          end
        end
      end
    end
  end
end
