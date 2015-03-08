module DevBox

	class Loader

		@file = ''
		@instanceName = ''
		@data = nil
    @@defaultData = {
     		'box' => 'hashicorp/precise64',
        'needPackagesUpdate' => true,
        'needPackagesUpgrade' => true,
        'needInstall' => [],
        'hosts' => [],
        'copyKeys' => false,
        'synced_folders' => {},
        'skip' => false,
        'gitSource' => {},
        'commandsBefore' => [],
        'commandsAfter' => [],
        'importSSHKeysFromDomains' => [],
        'config' => {},
        'importSSHKeysFromHere' => {}
    }

		def initialize(file)
			@file = file
			@instanceName = File.basename(file, '.*')

			@className = ""
			@instanceName.split('-').each do |n|
				@className += n.downcase.capitalize
			end			
		end

		def load()      
      puts 'Loading ' + @instanceName + '...'
      require 'rubygems'
      require 'json'      
      @data = JSON.parse(File.read(@file))      
      @data = @@defaultData.merge(@data)      
		end	

		def setup(cfg)
      if not @data['skip']
        require __dir__ + '/Configurator.rb'
        cfg.vm.define @instanceName do |server|          
          cfg = Configurator.new(server)
          data = @data
          data['instanceName'] = @instanceName
          cfg.setup data
        end
      end			
		end
		
	end

end