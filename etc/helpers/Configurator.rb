module DevBox
	
	class Configurator

			@server = nil

			def initialize(server)
				@server = server
			end

			def configure_ssh()
				@server.ssh.username = "vagrant"
				@server.ssh.password = "vagrant"
				@server.ssh.forward_agent = true
			end

			def register_hosts(hosts)
				if Vagrant.has_plugin?("vagrant-hostmanager")
					@server.hostmanager.enabled = true
					@server.hostmanager.manage_host = true
					@server.hostmanager.ignore_private_ip = false
					@server.hostmanager.include_offline = false
					@server.hostmanager.aliases = hosts
				end
			end

			def exec_shell_command(cmd)
				@server.vm.provision :shell, inline: cmd
			end

			def process_need_install(needInstall)
				if needInstall then
          self.exec_shell_command 'export DEBIAN_FRONTEND=noninteractive && apt-get -y install ' + needInstall.join(' ')
				end
			end

			def process_need_upgrade(needPackagesUpgrade)
				if needPackagesUpgrade then
					self.exec_shell_command "export DEBIAN_FRONTEND=noninteractive && apt-get -y upgrade"
				end
			end

			def process_need_update(needPackagesUpdate)
				if needPackagesUpdate then
					self.exec_shell_command "export DEBIAN_FRONTEND=noninteractive && apt-get -y update"
				end
			end

			def install_common_packages()
				self.exec_shell_command "export DEBIAN_FRONTEND=noninteractive && apt-get -y install mc rar unrar zip unzip nano curl lynx git subversion"
			end

			def process_synced_folders(syncedFolders)
        if syncedFolders then
          syncedFolders.each do |key, value|
            @server.vm.synced_folder key, value
            self.exec_shell_command "ln -s #{value} /home/vagrant/#{key}"
          end
        end
			end

			def process_copy_keys(copy_keys)
				if copy_keys then
					self.copy_keys "/home/vagrant/.ssh/", "vagrant", "vagrant"
					self.copy_keys "/root/.ssh/", "root", "root"
          self.exec_shell_command "eval `ssh-agent -s`"
          self.exec_shell_command "ssh-add ~/.ssh/sf_*"
				end        
			end

			def copy_keys(destination, user, group)
        self.guest_create_folder destination
				Dir.glob("~/.ssh/*").each do |file|
					tmp_name = File.basename(file)
					self.copy_file_to_server file, "#{destination}sf_#{tmp_name}"
				end
				self.guest_ch "mod", true, "0600", destination
				self.guest_ch "own", true, user, destination
				self.guest_ch "grp", true, group, destination
			end

			def copy_file_to_server(src, dest)
				@server.vm.provision :file, source: src, destination: dest
			end

			def guest_ch(changeWhat, recursive, new_status, dest)
				cmd = "ch#{changeWhat} "
				if recursive
					cmd = "#{cmd}-R "
				end
				cmd = "#{cmd} #{new_status} #{dest}"
				if recursive
					cmd = "#{cmd}/*"
				end
				self.exec_shell_command cmd
			end

			def configure_vm(box, instanceName)
				@server.vm.box = box
				@server.vm.hostname = instanceName
			end
      
      def guest_create_folder(folder)
        self.exec_shell_command "mkdir -p #{folder}"
      end
      
      def import_sshkey_from_domains(domains)
        if domains then
          self.exec_shell_command 'echo "" > /tmp/cy-imported-key'
          domains.each do |domain|
            self.exec_shell_command "ssh-keyscan #{domain} >> /tmp/cy-imported-key"
          end
          self.guest_create_folder "/root/.ssh/"
          self.guest_create_folder "/home/vagrant/.ssh/"
          self.guest_ch "mod", false, "0700", "/root/.ssh/"
          self.guest_ch "own", false, "root", "/root/.ssh/"
          self.guest_ch "grp", false, "root", "/root/.ssh/"
          self.guest_ch "mod", false, "0700", "/home/vagrant/.ssh/"
          self.guest_ch "own", false, "vagrant", "/home/vagrant/.ssh/"
          self.guest_ch "grp", false, "vagrant", "/home/vagrant/.ssh/"
          self.exec_shell_command "cat /tmp/cy-imported-key >> /root/.ssh/known_hosts"
          self.exec_shell_command "cat /tmp/cy-imported-key >> /home/vagrant/.ssh/known_hosts"
          self.exec_shell_command "rm -rf /tmp/cy-imported-key"
        end        
      end
      
      def process_git_clone(sources) 
        if sources then
          sources.each do |key, value|
            self.guest_create_folder value
            self.exec_shell_command "git clone #{key} #{value}"
            self.guest_ch 'own', true, 'vagrant', value
            self.guest_ch 'grp', true, 'vagrant', value
          end
        end
      end
      
      def process_svn_clone(sources) 
        if sources then
          sources.each do |key, value|            
            self.guest_create_folder value
            self.exec_shell_command "svn checkout #{key} #{value}"
            self.guest_ch 'own', true, 'vagrant', value
            self.guest_ch 'grp', true, 'vagrant', value
          end
        end
      end
      
      def exec_command_list(list)
        if list then
          list.each do |value|
            self.exec_shell_command value
          end
        end
      end

			def setup(data)
				self.configure_vm data['box'], data['instanceName']
				self.configure_ssh()
        self.exec_command_list data['commandsBefore']
				self.process_copy_keys data['copy_keys']
        self.import_sshkey_from_domains data['importSSHKeysFromDomains']
				self.process_need_update data['needPackagesUpdate']
				self.process_need_upgrade data['needPackagesUpgrade']
				self.install_common_packages()
				self.process_need_install data['needInstall']
				self.process_synced_folders data['syncedFolders']
				self.register_hosts data['hosts']
        self.process_git_clone data['gitSources']
        self.process_svn_clone data['svnSources']
        self.exec_command_list data['commandsAfter']
			end
		
	end

end