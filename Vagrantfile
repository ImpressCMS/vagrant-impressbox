# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ImpressCMS/DevBox-Ubuntu"

  require 'rubygems'
  require 'json'

  cfgFile = File.dirname(__FILE__) + "/config.json";
  if File.file?(cfgFile) then
	print "Loading config.json...\n"
	data = JSON.parse(File.read(cfgFile))
  else
	raise Vagrant::Errors::VagrantError.new, "config.json not found.\n"
  end

  if data.key?("forward_port") then
	print "Forwarding ports data found\n"
	data['forward_port'].each do |guest, host|		
		config.vm.network "forwarded_port", guest: guest, host: host
	end
  else
	print "Forwarding ports data not found (forward_port key in config.json)\n"
  end

  if data.key?("smb") then
	print "SMB config found\n"
	config.vm.synced_folder '.', '/vagrant',  id: "vagrant", :smb_host => data['smb']['ip'], :smb_password => data['smb']['pass'], :smb_username => data['smb']['user'], :user => 'www-data', :owner => 'www-data'
	#, :mount_options => ["file_mode=0664,dir_mode=0777"]
  end

  config.vm.provision "shell", inline: <<-SHELL
     # sudo apt-get update
     # sudo apt-get upgrade     
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

  if data.key?("icms") then
	data['icms'].each do |type, items|		
		items.each do |el_data|
			cmd = "cd /var/www/html/#{type}; if [ ! -d \""+  el_data['path']  + "\" ]; then "
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

end
