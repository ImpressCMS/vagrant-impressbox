# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION ||= "2"

# Detecting provider
if ARGV[1] and (ARGV[1].split('=')[0] == "--provider" or ARGV[2]) then
	provider = (ARGV[1].split('=')[1] || ARGV[2])
else
    provider = (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
end

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

def enumCfgVal(config, name, default, possible)
	value = stringCfgVal(config, name, default)
	if possible.include?(value) then
		return value
	else
		return default
	end
end

# Detect SSH keys
if cfgData.key?("keys") then
	if cfgData["keys"].key?("private") then
		if cfgData["keys"].key?("public") then
			private_key = cfgData["keys"]["private"]			
			public_key = cfgData["keys"]["public"]
			unless File.exist? private_key then
				raise Vagrant::Errors::VagrantError.new, "Private key defined in config.yaml can't be found (or accessible).\n"
			end
			unless File.exist? public_key then
				raise Vagrant::Errors::VagrantError.new, "Public key defined in config.yaml can't be found (or accessible).\n"
			end
		else
			private_key = cfgData["keys"]["private"] 			
			public_key = cfgData["keys"]["public"] + ".pub"
			unless File.exist? private_key then
				raise Vagrant::Errors::VagrantError.new, "Private key defined in config.yaml can't be found (or accessible).\n"
			end
			unless File.exist? public_key then
				raise Vagrant::Errors::VagrantError.new, "Can't find public key for defined in config private key.\n"
			end
		end
	else
		if cfgData["keys"].key?("public") then
			private_key = File.join(File.dirname(cfgData["keys"]["private"], File.basename(cfgData["keys"]["private"], ".pub")))
			public_key = cfgData["keys"]["public"]
			unless File.exist? private_key then
				raise Vagrant::Errors::VagrantError.new, "Can't find private key for defined in config public key.\n"
			end
			unless File.exist? public_key then
				raise Vagrant::Errors::VagrantError.new, "Public key defined in config.yaml can't be found (or accessible).\n"
			end
		end
	end
end

if not defined?(private_key) or private_key.nil? then
	possible_dirs = [
		File.join(__dir__, '.ssh'),
		File.join(__dir__, 'ssh'),
		File.join(__dir__, 'keys'),
		File.join(Dir.home(), '.ssh'),
		File.join(Dir.home(), 'keys')
	]
	
	possible_dirs.each do |dir|
		next unless Dir.exist?(dir)		

		Dir.entries(dir).each do |entry|
			entry = File.join(dir, entry)
			next unless File.file?(entry)						
			next unless File.extname(entry).eql?(".pub")

			next unless File.exist?(File.join(dir, File.basename(entry, ".pub")))

			private_key = File.join(dir, File.basename(entry, ".pub"))
			public_key = entry

			print "Private key autotected to #{private_key}\n"
			print "Public key autotected to #{public_key}\n"

			break
		end

		break if defined? private_key
	end

	possible_dirs = nil

	if not defined?(private_key) or private_key.nil? then
		raise Vagrant::Errors::VagrantError.new, "Can't autodetect your SSH keys. Please specify in config.yaml.\n"
	end
end

# Here goes real stuff!
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Box name to use for this vagrant configuration
  config.vm.box = "ImpressCMS/DevBox-Ubuntu"

  # Configure network
  config.vm.network "private_network",
	ip: cfgData["ip"]

  # Automatically check for update for this box ?
  config.vm.box_check_update = boolCfgVal(cfgData, "check_update", false)

  # SSH keys
  config.ssh.insert_key = true
  config.ssh.pty = false
  config.ssh.forward_x11 = false
  config.ssh.forward_agent = false
  config.ssh.private_key_path = File.dirname(private_key)

  # Forvard vars
  config.ssh.forward_env = ["APP_ENV"]

  # Configure ports
  if cfgData.key?('ports') then
    cfgData['ports'].each do |ports_group|
      config.vm.network "forwarded_port",
        guest: ports_group['guest'],
        host: ports_group['host'],
		protocol: enumCfgVal(ports_group, "protocol", "tcp", ["tcp", "udp"]),
		auto_correct: true
	  end
  else
	raise Vagrant::Errors::VagrantError.new, "At least one port should be defined in config.yaml.\n"
  end

  # Configure virtual box
  config.vm.provider "virtualbox" do |v|
    v.gui = boolCfgVal(cfgData, "gui", false)
	v.name = stringCfgVal(cfgData, "name", cfgData["name"])
	v.cpus = intCfgVal(cfgData, "cpus", 1)
	v.memory = intCfgVal(cfgData, "memory", 512)
  end

  # Configure hyperv
  config.vm.provider "hyperv" do |v|
	v.vmname = stringCfgVal(cfgData, "name", cfgData["name"])
	v.cpus = intCfgVal(cfgData, "cpus", 1)
	v.memory = intCfgVal(cfgData, "memory", 512)
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
	    config.vm.synced_folder '.', '/vagrant',
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
