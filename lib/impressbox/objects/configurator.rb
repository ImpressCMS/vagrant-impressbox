# Impressbox namespace
module Impressbox
  # Objects Namespace
  module Objects
    # Class used to configure instance
    class Configurator
      CONFIGURATORS = %w(
        HyperV
        VirtualBox).freeze

      # Initializator
      def initialize(root_config, machine, provider)
        @config = root_config
        @machine = machine
        load_configurators provider
      end

      def load_configurators(provider)
        @configurators = []
        CONFIGURATORS.each do |name|
          require_relative File.join('..', 'configurators', name.downcase)
          className = 'Impressbox::Configurators::' + name
          clazz = className.split('::').inject(Object) do |o, c|
            o.const_get c
          end
          instance = clazz.new(@config)
          @configurators.push instance if instance.same?(provider)
        end
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
        # @config.vm.provision 'shell', inline: <<-SHELL
        #      sudo -u root bash -c 'cd /srv/www/impresscms && chown -R www-data ./ && chgrp www-data ./ &&  git pull && chown -R www-data ./ && chgrp www-data ./'
        #      if [ ![ -L "/srv/www/impresscms" && -d "/srv/www/impresscms" ] ]; then
        #        echo "ImpressCMS dir setup running..."
        #        sudo -u root bash -c 'rm -rf /vagrant/impresscms/'
        #        sudo -u root bash -c 'mv /srv/www/impresscms /vagrant/'
        #        sudo -u root bash -c 'ln -s /vagrant/impresscms /srv/www/impresscms'
        #      fi
        # SHELL
      end

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

      # Box name to use for this vagrant configuration
      def name(name)
        @config.vm.box = name
      end

      # Configure SSH
      def configure_ssh(_public_key, _private_key)
        # @config.ssh.insert_key = true
        @config.ssh.pty = false
        @config.ssh.forward_x11 = false
        @config.ssh.forward_agent = false
        # @config.ssh.private_key_path = File.dirname(private_key)
      end

      def insert_ssh_key_if_needed(public_key, private_key)
        machine_update_public_key public_key
        machine_update_private_key private_key
      end

      def machine_update_public_key(public_key)
        key_contents = IO.read(public_key)
        cmd = "grep -Fxq #{key_contents} ~/.ssh/authorized_keys"
        unless @machine.communicate.test(cmd)
          puts 'Inserting public key to authorized_keys list'
          cmd = "echo #{key_contents} > ~/.ssh/authorized_keys"
          @machine.communicate.execute cmd
        end
      end

      def machine_update_private_key(private_key)
        puts 'Updating private key...'
        key_contents = IO.read(private_key)
        @machine.communicate.execute 'chmod 777 ~/.ssh/id_rsa'
        @machine.communicate.execute "echo #{key_contents} > ~/.ssh/id.rsa"
        @machine.communicate.execute 'chmod 400 ~/.ssh/id_rsa'
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
                       extract_protocol(pgroup)
        end
      end

      private

      def extract_protocol(pgroup)
        possible = %w(tcp udp)
        return 'tcp' unless pgroup.key?('protocol')
        return 'tcp' unless possible.include?(pgroup['protocol'])
        pgroup[protocol]
      end
    end
  end
end
