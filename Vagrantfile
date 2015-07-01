# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "MekDrop/ImpressCMS-DevBox"

  require 'rubygems'
  require 'json'

  if File.file?("config.json") then
	print "Loading config.json...\n"
	data = JSON.parse(File.read("config.json"))
  else
	print "config.json not found.\n"
	data = JSON.parse("{}")
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
	config.vm.synced_folder '.', '/vagrant', :smb_host => data['smb']['ip'], :smb_password => data['smb']['pass'], :smb_username => data['smb']['user']
  end

  config.vm.provision "shell", inline: <<-SHELL
     # sudo apt-get update
     # sudo apt-get upgrade
     sudo -u root bash -c 'cd /srv/www/impresscms && git pull' 
     sudo -u root bash -c 'cd /srv/www/phpmyadmin && git pull'
     sudo -u root bash -c 'cd /srv/www/Memchaced-Dashboard && git pull'
     sudo -u root bash -c 'rm -rf /vagrant/impresscms/'
     sudo -u root bash -c 'mv /srv/www/impresscms /vagrant/'
     sudo -u www-data bash -c 'ln -s /vagrant/impresscms /srv/www/impresscms'
  SHELL

  if data.key?("icms_modules") then
	data['icms_modules'].each do |module_data|
		cmd = "cd /var/www/modules"
		case type.downcase
		when "svn"
			cmd = "#{cmd} && svn co #(module_data.url)"
		when "git"
			cmd = "#{cmd} && git checkout #(module_data.url)"
		else
			print "#{type} is not supported"
		end
		if module_data.key?("path") then
			cmd = "#{cmd} #{module_data.path}"
		end
		config.vm.provision "shell", inline: "sudo -u www-data bash -c '#{cmd}'"
	end
  end

end
