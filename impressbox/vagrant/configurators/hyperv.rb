module Impressbox
  module Vagrant
    module Configurators
      # HyperV configurator
      class HyperV < Impressbox::Vagrant::Configurators::Base
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
          if cfg.key?('smb')
            error 'HyperV provider needs defined smb options in config.yaml.'
          end
          ip = Cval.str(cfg['smb'], 'ip')
          password = Cval.str(cfg['smb'], 'pass')
          username = Cval.str(cfg['smb'], 'user')
          samba_configure ip, password, username
        end

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
end
