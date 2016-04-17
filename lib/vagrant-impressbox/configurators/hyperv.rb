require_relative 'base'

module Impressbox
  # Configurators namespace
  module Configurators
    # HyperV configurator
    class HyperV < Impressbox::Configurators::Base
      # Configure basic settings
      def basic_configure(vmname, cpus, memory, _gui)
        @config.vm.provider 'hyperv' do |v|
          v.vmname = vmname
          v.cpus = cpus
          v.memory = memory
        end
      end

      # Configure specific
      def specific_configure(cfg)
        samba_configure cfg.ip, cfg.pass, cfg.user
      end

      private

      # Configure samba
      def samba_configure(ip, password, username)
        @config.vm.synced_folder '.', '/vagrant',
                                 id: 'vagrant',
                                 smb_host: ip,
                                 smb_password: password,
                                 smb_username: username,
                                 user: 'www-data',
                                 owner: 'www-data'
      end
    end
  end
end
