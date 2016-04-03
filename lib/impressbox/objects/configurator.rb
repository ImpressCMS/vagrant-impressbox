require_relative 'template'

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

      # Box name to use for this vagrant configuration
      def name(name)
        @config.vm.box = name
      end

      # Configure SSH
      def configure_ssh(public_key, private_key)
        # @config.ssh.insert_key = true
        @config.ssh.pty = false
        @config.ssh.forward_x11 = false
        @config.ssh.forward_agent = false
        # @config.ssh.private_key_path = File.dirname(private_key)
        insert_ssh_key_if_needed public_key, private_key
      end

      def insert_ssh_key_if_needed(public_key, private_key)
        @machine.communicate.wait_for_ready 60

        machine_private_key @machine.communicate, private_key
        machine_public_key @machine.communicate, public_key
      end

      def machine_public_key(communicator, public_key)
        puts 'Updating public key...'
        machine_upload_file communicator, public_key, '~/.ssh/id_rsa.pub'
        communicator.execute 'touch ~/.ssh/authorized_keys'
        communicator.execute 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'
        communicator.execute "echo `awk '!a[$0]++' ~/.ssh/authorized_keys` > ~/.ssh/authorized_keys"
        communicator.execute 'chmod 600 ~/.ssh/id_rsa.pub'
      end

      def machine_private_key(communicator, private_key)
        puts 'Updating private key...'
        machine_upload_file communicator, private_key, '~/.ssh/id_rsa'
        communicator.execute 'chmod 400 ~/.ssh/id_rsa'
      end

      def machine_upload_file(communicator, src_file, dst_file)
        communicator.execute 'chmod 777 ' + dst_file + ' || :'
        communicator.execute 'touch ' + dst_file
        communicator.execute 'truncate -s 0 ' + dst_file
        text = File.open(src_file).read
        text.gsub!(/\r\n?/, "\n")
        text.each_line do |line|
          communicator.execute "echo \"#{line.rstrip}\" >> #{dst_file}"
        end
      end

      def machine_wait_for_ssh(communicator)
        unless communicator.ready?
          (0..20).each do
            sleep 5
            break if communicator.ready?
          end
          unless communicator.ready?
            raise "Can't communicate with machine through SSH"
          end
        end
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
