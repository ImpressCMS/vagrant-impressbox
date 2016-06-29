module Impressbox
  module Configurators
    module Provision
      # Configures provision script
      class RunShell < Impressbox::Abstract::ConfiguratorProvision

        # Creates Template shortcut
        Template = Impressbox::Objects::Template

        # Returns description
        #
        #@return [String]
        def description
          I18n.t 'configuring.provision'
        end

        # Can be executed ?
        #
        #@param machine     [::Vagrant::Machine]                Current machine
        #@param config_file [::Impressbox::Objects::ConfigFile] Loaded config file data
        #
        #@return            [Boolean]
        def can_be_configured?(machine, config_file)
          p = config_file.provision
          p.is_a?(String) && p.strip.length > 0
        end

        # Configure machine on provision
        #
        #@param machine         [::Vagrant::Machine]                Current machine
        #@param config_file     [::Impressbox::Objects::ConfigFile] Loaded config file data
        def configure(machine, config_file)
          host_file = make_tmp_file(config_file.provision)
          guest_file = '/tmp/' + File.basename(host_file)
          exec_on_machine machine, 'rm -rf ' + guest_file
          machine.communicate.upload host_file, guest_file
          exec_on_machine machine, 'bash ' + guest_file
          exec_on_machine machine, 'rm -rf ' + guest_file
        end

        private

        # Makes temp file from commands and return filename
        #
        #@param commands [String] Commmands to save
        #
        #@return [String]
        def make_tmp_file(commands)
          require 'tempfile'
          file = Tempfile.new('impressbox-run_shell', {
            :encoding => 'UTF-8',
            :textmode => true,
            :autoclose => false,
            :universal_newline => true
          })
          tpl = Template.new
          contents = commands.gsub(/\r\n?/, "\n")
          path = file.path
          file.write tpl.render_string(contents)
          file.close
          path
        end

        # Execute command on machine
        #
        #@param machine  [::Vagrant::Machine]   Current machine
        #@param cmd      [String]
        def exec_on_machine(machine, cmd)
          machine.communicate.execute(cmd) do |type, data|
            write_output machine, type, data
          end
        end

        # Gets line color by output type
        #
        #@param type [Symbol] Result type
        #
        #@return [Symbol]
        def line_color(type)
          return :green if type == :stdout
          :red
        end

        # Writes output to console
        #
        #@param machine  [::Vagrant::Machine]   Current machine
        #@param type     [Symbol]               Output type
        #@param data     [String]               Output data
        def write_output(machine, type, data)
          data = data.chomp
          return unless data.length > 0

          machine.ui.info data, :color => line_color(type)
        end
      end
    end
  end
end
