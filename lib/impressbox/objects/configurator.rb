require_relative 'template'

# Impressbox namespace
module Impressbox
  # Objects Namespace
  module Objects
    # Class used to configure instance
    class Configurator
      CONFIGURATORS = %w(
        HyperV
        VirtualBox
      ).freeze

      # Initializator
      def initialize(root_config, machine, provider)
        @config = root_config
        @machine = machine
        @template = Impressbox::Objects::Template.new
        load_configurators provider
      end

      def load_configurators(provider)
        @configurators = []
        CONFIGURATORS.each do |name|
          require_relative File.join('..', 'configurators', name.downcase)
          class_name = 'Impressbox::Configurators::' + name
          clazz = class_name.split('::').inject(Object) do |o, c|
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
      
      # Sets code to execute on provision
      def configure_provision(code)
        @config.vm.provision "shell", inline: code
      end

      # Box name to use for this vagrant configuration
      def name(name)
        @config.vm.box = name
      end

      # Configure exec
      def configure_exec(cmd)
        @config.exec.commands '*', prepend: cmd
        system 'vagrant exec --binstubs' unless File.exist? 'bin'
      end

      # Configure SSH
      def configure_ssh(public_key, private_key)
        # @config.ssh.insert_key = true
        @config.ssh.pty = false
        @config.ssh.forward_x11 = false
        @config.ssh.forward_agent = false
        Impressbox::Plugin.set_item :public_key, public_key
        Impressbox::Plugin.set_item :private_key, private_key
        # @config.ssh.private_key_path = File.dirname(private_key)
      end

      # Configure network
      def configure_network(ip)
        return unless ip
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
