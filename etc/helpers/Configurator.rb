module DevBox
	
	class Configurator

			@server = nil
      @buffer_enabled = false
      @cmd_buffer = ""

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
      
      def start_cmd_buffer(action_name)
        @buffer_enabled = true
        @cmd_buffer = "export DEBIAN_FRONTEND=noninteractive \n "
        self.echo action_name
      end
      
      def end_cmd_buffer()
        @buffer_enabled = false
        self.exec_shell_command @cmd_buffer
        @cmd_buffer = false
      end

			def exec_shell_command(cmd)
        if @buffer_enabled then
          @cmd_buffer = @cmd_buffer + cmd + " \n "
        else
          @server.vm.provision :shell, inline: cmd
        end				
			end
      
      def echo(text)
        self.exec_shell_command "echo #{text.dump}"
      end

			def process_need_install(needInstall)
				if needInstall then
          apps = needInstall.join(' ')
          self.start_cmd_buffer "Installing #{apps}..."
          self.exec_shell_command "apt-get -y install #{apps}"
          self.end_cmd_buffer
				end
			end

			def process_need_upgrade(needPackagesUpgrade)
				if needPackagesUpgrade then
          self.start_cmd_buffer "Upgrading packages on virtual machine..."
					self.exec_shell_command "apt-get -y upgrade"
          self.end_cmd_buffer
				end
			end

			def process_need_update(needPackagesUpdate)
				if needPackagesUpdate then
          self.start_cmd_buffer "Updating packages on virtual machine..."
					self.exec_shell_command "apt-get -y update"
          self.end_cmd_buffer
				end
			end

			def install_common_packages()
        self.start_cmd_buffer "Installing common packages..."
				self.exec_shell_command "apt-get -y install keychain coreutils  mc rar unrar zip unzip nano curl lynx git subversion"
        self.end_cmd_buffer
			end

			def process_synced_folders(syncedFolders)
        if syncedFolders then
          self.start_cmd_buffer "Configuring synced folders..."
          syncedFolders.each do |key, value|
            @server.vm.synced_folder key, value
            self.exec_shell_command "ln -s #{value} /home/vagrant/#{key}"
          end
          self.end_cmd_buffer
        end
			end

			def process_copy_keys(copy_keys)
				if copy_keys then
          self.start_cmd_buffer "Copying keys fromk host to guest and enabling..."
          self.exec_shell_command "eval `keychain --eval id_rsa`"
					self.copy_keys "/home/vagrant/.ssh/"          
          self.end_cmd_buffer
				end        
			end
      
      def init_ssh_keys() 
        self.start_cmd_buffer "Initializing ssh keys..."
        @imported_ssh_keys = []
        self.guest_create_folder "/root/.ssh/"
        self.guest_create_folder "/home/vagrant/.ssh/"
        self.guest_ch "mod", false, "0700", "/root/.ssh/"
        self.guest_ch "own", false, "root", "/root/.ssh/"
        self.guest_ch "grp", false, "root", "/root/.ssh/"
        self.guest_ch "mod", false, "0700", "/home/vagrant/.ssh/"
        self.guest_ch "own", false, "vagrant", "/home/vagrant/.ssh/"
        self.guest_ch "grp", false, "vagrant", "/home/vagrant/.ssh/"
        self.end_cmd_buffer
      end
      
      def write_keys_script()
        self.start_cmd_buffer "Writing ssh keys script..."
        lines = "#!/bin/bash
        
        eval `keychain --eval id_rsa`
        
        "
        @imported_ssh_keys.each do |key|
          lines += "ssh-add #{key}
          "
        end
        file = "/home/vagrant/import-session-keys.sh"
        self.write_to_guest_file file, lines
        self.guest_ch 'own', false, 'vagrant', file
        self.guest_ch 'grp', false, 'vagrant', file
        self.guest_ch 'mod', false, '0700', file
        self.end_cmd_buffer
      end

			def copy_keys(destination)
        self.guest_create_folder destination
        require 'find'
        require "base64"
        [Dir.home + "/.ssh", "./keys"].each do |place|
          Dir.chdir(place) do
            Find.find('.') do |file|
              if File.file?(file) then
                ext = File.extname(file)
                basename = File.basename(file, ext)
                tmp_name = destination + "/" + Base64.strict_encode64(place) + "_" + basename + ext
                if ["authorized_keys", "known_hosts"].include?(basename) then
                  next
                end                
                self.copy_file_to_server place + "/" + file, tmp_name
                if not ext == '.pub' then
                  @imported_ssh_keys.push tmp_name
                end
              end              
            end
          end          
        end
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
      
      def setup_ssh_paths()
        self.exec_shell_command "cat /tmp/cy-imported-key >> /root/.ssh/known_hosts"
        self.exec_shell_command "cat /tmp/cy-imported-key >> /home/vagrant/.ssh/known_hosts"
        self.exec_shell_command "rm -rf /tmp/cy-imported-key"
        self.exec_shell_command "sort /root/.ssh/known_hosts | uniq -u | wc -l"
        self.exec_shell_command "sort /home/vagrant/.ssh/known_hosts | uniq -u | wc -l"
      end
      
      def import_sshkey_from_domains(domains)
        self.exec_shell_command 'echo "" > /root/.ssh/known_hosts'
        self.exec_shell_command 'echo "" > /home/vagrant/.ssh/known_hosts'
        if domains then
          self.start_cmd_buffer "Automatically importing SSH keys from domains..."
          self.exec_shell_command 'echo "" > /tmp/cy-imported-key'
          domains.each do |domain|
            self.exec_shell_command "ssh-keyscan #{domain} >> /tmp/cy-imported-key"
          end
          self.setup_ssh_paths
          self.end_cmd_buffer
        end  
      end
      
      def import_sshkey_from_here(data)
        if data then
          self.start_cmd_buffer "Import SSH Keys from configuration..."
          self.exec_shell_command 'echo "" > /tmp/cy-imported-key'
          content = ""
          data.each do |item|
            content = content + item["hosts"].join(',') + " ssh-" + item["type"] + " " + item["key"] + "\n"
          end
          self.write_to_guest_file "/tmp/cy-imported-key", content
          self.setup_ssh_paths
          self.end_cmd_buffer
        end        
      end
      
      def process_git_clone(sources) 
        if sources then
          self.start_cmd_buffer "Git clonning..."
          sources.each do |key, value|
            self.guest_create_folder value
            self.exec_shell_command "/home/vagrant/import-session-keys.sh && git clone #{key} #{value}"
            self.guest_ch 'own', true, 'vagrant', value
            self.guest_ch 'grp', true, 'vagrant', value
          end
          self.end_cmd_buffer
        end
      end
      
      def process_svn_clone(sources) 
        if sources then
          self.start_cmd_buffer "SVN Clonning..."
          self.exec_shell_command '/home/vagrant/import-session-keys.sh'
          sources.each do |key, value|            
            self.guest_create_folder value
            self.exec_shell_command "svn checkout #{key} #{value}"
            self.guest_ch 'own', true, 'vagrant', value
            self.guest_ch 'grp', true, 'vagrant', value
          end
          self.end_cmd_buffer
        end
      end
      
      def exec_command_list(list)
        if list then
          self.start_cmd_buffer "Execute commands list from config..."
          list.each do |value|
            self.exec_shell_command value
          end
          self.end_cmd_buffer
        end
      end
      
      def write_to_guest_file(filename, content)
        require "base64"
        first = true
        content.split("\n").each do |line|
          line = Base64.strict_encode64(line)
          cmd = "echo `echo \"#{line}\" | base64 --decode` >"
          if first then
            cmd += " " + filename
            first = false
          else
            cmd += "> " + filename
          end
          self.exec_shell_command cmd
        end        
      end
      
      def process_config(config)
        if config then
          self.start_cmd_buffer "Writing configs on guest..."
          config.each do |filename, content|
            if content.kind_of?(Array) then
              content = content.join("\n")
            end            
            self.write_to_guest_file filename, content
          end
          self.end_cmd_buffer
        end
      end

			def setup(data)
				self.configure_vm data['box'], data['instanceName']
				self.configure_ssh()
        
        self.exec_command_list data['commandsBefore']
        
        self.process_need_update data['needPackagesUpdate']        
				self.process_need_upgrade data['needPackagesUpgrade']
        self.install_common_packages()
        
        self.init_ssh_keys()
				self.process_copy_keys data['copyKeys']
        self.import_sshkey_from_domains data['importSSHKeysFromDomains']
        self.import_sshkey_from_here data['importSSHKeysFromHere']
        self.write_keys_script()
        
				self.process_need_install data['needInstall']
				self.process_synced_folders data['syncedFolders']
				self.register_hosts data['hosts']
        self.process_git_clone data['gitSource']
        self.process_svn_clone data['svnSource']
        self.process_config data['config']
        self.exec_command_list data['commandsAfter']
			end
		
	end

end