# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Box name to use for this vagrant configuration
  config.vm.box = "ImpressCMS/DevBox-Ubuntu"

  # Load required libraries
  require 'rubygems'
  require 'json'

  # Load and parse config.json
  cfgFile = File.join(__dir__, "/config.json")
  if File.file?(cfgFile) then
	print "Loading config.json...\n"		
	data = File.read(cfgFile);
	if data.nil? || data.empty? then
		raise Vagrant::Errors::VagrantError.new, "config.json is empty.\n"
	end
	data = JSON.parse(data)
	if data.nil? then
		raise Vagrant::Errors::VagrantError.new, "config.json contains bad data.\n"
	end
  else
	raise Vagrant::Errors::VagrantError.new, "config.json not found.\n"
  end  	

  # Detecting provider
  if ARGV[1] and \
	   (ARGV[1].split('=')[0] == "--provider" or ARGV[2])
    provider = (ARGV[1].split('=')[1] || ARGV[2])
  else
    provider = (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
  end

  # Setup virtualbox (if we use this system)
  if provider.to_s == "virtualbox" then
	print "Configuring virtualbox..."
    data['forward_port'].each do |guest, host|
      config.vm.network "forwarded_port", guest: guest, host: host
    end
  end

  # Setup hyperv (if we use this system)
  if provider == "hyperv" then
    print "Configuring hyperv..."
    if data.key?("smb") then
      raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, smb array must be defined in config.json.\n"		
	elsif data['smb'].key?("ip") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, ip in smb array in config.json must be defined.\n"		
	elsif data['smb'].key?("pass") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, pass in smb array in config.json must be defined.\n"		
	elsif data['smb'].key?("user") then
	  raise Vagrant::Errors::VagrantError.new, "Because you are using hyperv, user in smb array in config.json must be defined.\n"		
	else
	    override.vm.synced_folder '.', '/vagrant',  id: "vagrant", :smb_host => data['smb']['ip'], :smb_password => data['smb']['pass'], :smb_username => data['smb']['user'], :user => 'www-data', :owner => 'www-data'
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

  # Checkouts icms modules
  if data.key?("icms") then
	data['icms'].each do |type, items|
		config.vm.provision "shell", inline: "echo 'Checking out {#type}...';"
		items.each do |el_data|
			cmd = "cd /vagrant/impresscms/htdocs/#{type}; if [ ! -d \""+  el_data['path']  + "\" ]; then "
			case el_data['type'].downcase
			when "svn"
				cmd = cmd + " svn co " + el_data['url'] + " " + el_data['path'] + "; fi; "
			when "git"
				cmd = cmd + " git clone " + el_data['url'] + " " + el_data['path'] + "; fi;"
				if el_data.key?("branch") then
					cmd = cmd + "git checkout " + el_data['branch'] + ";"; 
				end
			else
				print el_data['type'] + " is not supported"
			end
			config.vm.provision "shell", inline: "sudo -u root bash -c '" + cmd +"'"
		end
		config.vm.provision "shell", inline: "sudo -u root bash -c 'cd /var/www/html/#{type} && chown -R www-data ./ && chgrp www-data ./' "
	end	
  end

  config.vm.provision "shell", inline: "echo 'Provision finished.';"

end
