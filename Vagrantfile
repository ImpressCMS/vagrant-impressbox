# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
	
	require __dir__ + '/etc/helpers/Loader.rb'

	Dir.glob(__dir__ + '/etc/boxes/*.json').each do |file|
		loader = DevBox::Loader.new(file)
		loader.load()
		loader.setup(config)
	end 
     
end
