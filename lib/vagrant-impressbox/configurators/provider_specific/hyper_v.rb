module Impressbox
  module Configurators
    module ProviderSpecific
      # HyperV configurator
      class HyperV < Impressbox::Abstract::ConfiguratorProviderSpecific
        # Configure basic settings
        #
        #@param vagrant_config  [Object]  Current vagrant config
        #@param vmname          [String]  Virtual machine name
        #@param cpus            [Integer] CPU count
        #@param memory          [Integer] Memory count
        #@param gui             [Boolean] Use GUI?
        def basic_configure(vagrant_config, vmname, cpus, memory, _gui)
          vagrant_config.vm.provider 'hyperv' do |v|
            v.vmname = vmname
            v.cpus = cpus
            v.memory = memory
          end
        end

        # Configure specific
        #
        #@param vagrant_config  [Object]                            Current vagrant config
        #@param cfg             [::Impressbox::Objects::ConfigFile] Loaded config file data
        def specific_configure(vagrant_config, cfg)
          samba_configure vagrant_config, cfg.ip, cfg.pass, cfg.user
        end

        private

        # Configure Samba
        #
        #@param vagrant_config  [Object] Current vagrant config
        #@param ip              [String] Machine IP
        #@param password        [String] Password
        #@param username        [String] Username
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
