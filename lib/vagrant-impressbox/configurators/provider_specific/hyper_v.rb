module Impressbox
  module Configurators
    module ProviderSpecific
      # HyperV configurator
      class HyperV < Impressbox::Configurators::AbstractProviderSpecific
        # Configure basic settings
        def basic_configure(vagrant_config, vmname, cpus, memory, _gui)
          vagrant_config.vm.provider 'hyperv' do |v|
            v.vmname = vmname
            v.cpus = cpus
            v.memory = memory
          end
        end

        # Configure specific
        def specific_configure(vagrant_config, cfg)
          samba_configure vagrant_config, cfg.ip, cfg.pass, cfg.user
        end

        private

        # Configure samba
        def samba_configure(vagrant_config, ip, password, username)
          vagrant_config.vm.synced_folder '.', '/vagrant',
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
end
