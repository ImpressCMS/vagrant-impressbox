# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION ||= "2"

# Detect config.yaml location 
if File.exist? File.join(__dir__, 'config.yaml')
	cfgFile = File.join(__dir__, 'config.yaml')
elsif File.exist? File.join(ENV['vbox_config_path'], 'config.yaml')
	cfgFile = File.join(ENV['vbox_config_path'], 'config.yaml')	
else
	raise Vagrant::Errors::VagrantError.new, "config.yaml not found.\n"
end

# Install vagrant-hostmanager plugin if needed
unless Vagrant.has_plugin?("vagrant-hostmanager")
    system "vagrant plugin install vagrant-hostmanager"
    system "vagrant up"
    exit true
end

# Loads required libraries
require 'yaml'
#require 'rubygems'

# Load and parse config.yaml
cfgData = begin
  YAML.load	File.open(cfgFile)
rescue ArgumentError => e
  raise Vagrant::Errors::VagrantError.new, "Could not parse YAML: #{e.message}\n"
end

# Some functions
def boolCfgVal(config, name, default)
	if config.key?(name) then
		if config[name] then 
			return true
		else
			return false
		end
	else
		return default
	end
end

def stringCfgVal(config, name, default)
	if config.key?(name) then
		vdata = config[name]
		return "#{vdata}"
	else
		return default
	end
end

def intCfgVal(config, name, default)
	if config.key?(name) then
		vdata = config[name]
		return "#{vdata}".to_i
	else
		return default
	end
end


# Here goes real stuff!
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Box name to use for this vagrant configuration
  config.vm.box = "ImpressCMS/DevBox-Ubuntu"

  # Configure network
  config.vm.network "private_network",
	ip: cfgData["ip"]

  # Configure ports
  cfgData['ports'].each do |ports_group|
    config.vm.network "forwarded_port",
	  guest: ports_group['guest'],
	  host: ports_group['host']
  end

  # Configure virtual box
  config.vm.provider "virtualbox" do |v|
    v.gui = boolCfgVal(cfgData, "gui", false)
	v.name = stringCfgVal(cfgData, "name", config.vm.box)
	v.cpus = intCfgVal(cfgData, "cpus", 1)
	v.memory = intCfgVal(cfgData, "memory", 512)
  end

  # Configure hyperv
  config.vm.provider "hyperv" do |v|
    v.gui = boolCfgVal(cfgData, "gui", false)
	v.vmname = stringCfgVal(cfgData, "name", config.vm.box)
	v.cpus = intCfgVal(cfgData, "cpus", 1)
	v.memory = intCfgVal(cfgData, "memory", 512)
	v.mac = intCfgVal(cfgData, "mac", nil)
  end

  # Detecting provider
  if ARGV[1] and (ARGV[1].split('=')[0] == "--provider" or ARGV[2]) then
    provider = (ARGV[1].split('=')[1] || ARGV[2])
  else
    provider = (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
  end

  # Setup hyperv (if we use this system)
  if provider == "hyperv" then
    if cfgData.key?("smb") then
      raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, smb array must be defined in config.yaml.\n"		
	elsif cfgData['smb'].key?("ip") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, ip in smb array in config.yaml must be defined.\n"		
	elsif cfgData['smb'].key?("pass") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, pass in smb array in config.yaml must be defined.\n"		
	elsif cfgData['smb'].key?("user") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, user in smb array in config.yaml must be defined.\n"		
	else
	    override.vm.synced_folder '.', '/vagrant',
			id: "vagrant",
			:smb_host => cfgData['smb']['ip'],
			:smb_password => cfgData['smb']['pass'],
			:smb_username => cfgData['smb']['user'],
			:user => 'www-data',
			:owner => 'www-data'
	end
  end

  # Profision config
  config.vm.provision "shell", inline: <<-SHELL
     # sudo apt-get update
     # sudo apt-get upgrade     
	 echo "Fixing folder rights..."
     sudo -u root bash -c 'cd /srv/www/impresscms && chown -R www-data ./ && chgrp www-data ./ &&  git pull && chown -R www-data ./ && chgrp www-data ./' 
     sudo -u root bash -c 'cd /srv/www/phpmyadmin && chown -R www-data ./ && chgrp www-data ./ && git pull && chown -R www-data ./ && chgrp www-data ./'
     sudo -u root bash -c 'cd /srv/www/Memchaced-Dashboard && chown -R www-data ./ && chgrp www-data ./ && git pull && chown -R www-data ./ && chgrp www-data ./'
     if [[ -L "/srv/www/impresscms" && -d "/srv/www/impresscms" ]]; then
	     echo "ImpressCMS dir setuped. Skipping..."
     else
	     echo "ImpressCMS dir setup running..."
	     sudo -u root bash -c 'rm -rf /vagrant/impresscms/'
	     sudo -u root bash -c 'mv /srv/www/impresscms /vagrant/'
	     sudo -u root bash -c 'ln -s /vagrant/impresscms /srv/www/impresscms'
     fi
  SHELL

end
