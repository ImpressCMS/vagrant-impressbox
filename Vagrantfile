# -*- mode: ruby -*-
# vi: set ft=ruby :

# Defines a module that is used for all stuff to make all the magic happen

module ImpressCMSBox
  # Config values parsing
  class Cval
    # Parses bool value
    def self.bool(config, name, default = nil)
      return default unless config.key?(name)
      return true if config[name]
      false
    end

    # Parses string value
    def self.str(config, name, default = nil)
      return config[name].to_s if config.key?(name)
      default
    end

    # Parses Int value
    def self.int(config, name, default = nil)
      return config[name].to_s.to_i if config.key?(name)
      default
    end

    # Parses Enum value
    def self.enum(config, name, default, possible)
      value = str(config, name, default)
      return value if possible.include?(value)
      default
    end
  end

  # here goes all functions that can be triggered
  # for any delivered class
  class BaseObject
    def error(msg)
      raise ::Vagrant::Errors::VagrantError.new, "#{msg}\n"
    end
  end

  # Keys handling class
  class Keys
    # variable for public key
    @public = nil

    # variable for private key
    @private = nil

    # create instance from config data
    def self.create_from_config(config)
      new(
        (config['keys']['private'] if config['keys'].key?('private')),
        (config['keys']['public'] if config['keys'].key?('public'))
      )
    end

    # Initializer
    def initialize(private_key = nil, public_key = nil)
      @public = public_key
      @private = private_key
    end

    # Are both variables empty?
    def empty?
      @private.nil? && @public.nil?
    end

    # Are both variables not filled?
    def filled?
      !@private.nil? && !@public.nil?
    end

    # prints variables contents to console
    def print
      print_key 'Public', @public
      print_key 'Private', @private
    end

    # print variable logic
    def print_key(name, value)
      if value.nil?
        print name + ' key was undetected'
      else
        print name + ' key autotected to ' + value.to_s + "\n"
      end
    end

    # makes some methods for this class private
    private :print_key
  end

  # SSH key detect
  class SSHkeyDetect < ImpressCMSBox::BaseObject
    # Keys
    @keys = nil

    # Binded config
    @config = nil

    # Quick way for detect
    def self.detect(config)
      instance = new(config)
      instance.keys
    end

    # initializer
    def initialize(config)
      @keys = Keys.new
      @config = config
      try_config if @config.key?('keys')
      try_filesystem unless @keys.empty?
    end

    # try config data and validates result
    def try_config
      return unless @config.key?('keys')
      @keys = @detect_ssh_keys_from_config
      err_msg = validate_from_config ssh_keys
      error err_msg unless err_msg.nil?
    end

    # try filesystem detection and validates result
    def try_filesystem
      @keys = @detect_ssh_keys_from_filesystem
      if @keys.empty?
        error "Can't autodetect SSH keys. Please specify in config.yaml."
      end
      @keys.print
    end

    # validates data from config
    def validate_from_config(keys)
      return nil if keys.empty?
      unless keys['private'].nil? || (!File.exist? keys['private'])
        return "Private key defined in config.yaml can't be found."
      end
      unless File.exist? keys['public']
        return "Public key defined in config.yaml can't be found."
      end
    end

    # Try detect SSH keys by using only a config
    def detect_ssh_keys_from_config
      ret = Key.create_from_config(@config)

      return ret if ret.empty? || ret.filled?

      if private_defined
        ret.public = ret.private + '.pub'
        return ret
      end

      ret.private = private_filename_from_public(ret.private)
      ret
    end

    # Try detect SSH keys by using local filestystem
    def detect_ssh_keys_from_filesystem
      @ssh_keys_search_paths.each do |dir|
        keys = iterate_dir_fs(dir)
        return keys unless keys.empty?
      end
      Keys.new
    end

    # used in detect_ssh_keys_from_filesystem
    def iterate_dir_fs(dir)
      Dir.entries(dir).each do |entry|
        entry = File.join(dir, entry)
        next unless good_file_on_filesystem?(entry)
        return Keys.new(
          private_filename_from_public(entry),
          entry
        )
      end
      Keys.new
    end

    # converts private SSH key to public
    def private_filename_from_public(filename)
      File.join(
        File.dirname(
          filename,
          File.basename(
            filename,
            '.pub'
          )
        )
      )
    end

    # is a correct file in filesystem tobe a SSH key?
    def good_file_on_filesystem?(filename)
      File.file?(filename) && \
        File.extname(filename).eql?('.pub') && \
        File.exist?(private_filename_from_public(filename))
    end

    # gets paths for looking for SSH keys
    def ssh_keys_search_paths
      [
        File.join(__dir__, '.ssh'),
        File.join(__dir__, 'ssh'),
        File.join(__dir__, 'keys'),
        File.join(Dir.home, '.ssh'),
        File.join(Dir.home, 'keys')
      ].reject do |dir|
        !Dir.exist?(dir)
      end
    end

    # Makes some methods private
    private :detect_ssh_keys_from_config,
            :detect_ssh_keys_from_filesystem,
            :try_config,
            :try_filesystem,
            :validate_from_config,
            :iterate_dir_fs,
            :good_file_on_filesystem?,
            :private_filename_from_public
  end

  # Config class
  class Config < ImpressCMSBox::BaseObject
    # config data
    @config = []

    # method for fast reading all config to variable
    def self.read
      instance = new
      instance.config
    end

    # Initializer
    def initialize
      @config_file = @detect_yaml_config
      error 'config.yaml not found.' if @config_file.nil?
      @config = @load_config
    end

    # Loads configuration
    def load_config
      require 'yaml'

      begin
        YAML.load	File.open(@config_file)
      rescue ArgumentError => e
        error "Could not parse YAML: #{e.message}"
      end
    end

    # Detect config.yaml location
    def detect_yaml_config
      if File.exist? File.join(__dir__, 'config.yaml')
        return File.join(__dir__, 'config.yaml')
      elsif File.exist? File.join(ENV['vbox_config_path'], 'config.yaml')
        return File.join(ENV['vbox_config_path'], 'config.yaml')
      end
      nil
    end

    # Makes some methods private
    private :load_config,
            :detect_yaml_config
  end

  # Module for vagrant stuff
  module Vagrant
    # Vagrant plugins management
    class Plugins
      # Defines required vagrant plugins
      PLUGINS = [
        'vagrant-hostmanager'
      ].freeze

      # Initializer
      def initialize
        load if ARGV.include?('up')
      end

      # Loads all plugins defined in VAGRANT_PLUGINS constant
      def load
        needed_reboot = false
        PLUGINS.each do |plugin|
          unless Vagrant.has_plugin?(plugin)
            system 'vagrant plugin install ' + plugin
            needed_reboot = true
          end
        end
        return unless needed_reboot
        system 'vagrant up'
        exit true
      end

      # make some methods private
      private :load
    end

    # Info about vagrant
    class Info
      # Provider
      @provider = nil

      # Api version
      @api_version = '2'.freeze

      # Initializer
      def initialize
        @provider = @detect_provider
      end

      # Detecting provider
      def detect_provider
        if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
          return (ARGV[1].split('=')[1] || ARGV[2])
        end
        (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
      end

      # Make some methods private
      private :detect_provider
    end

    # Configurators
    module Configurators
      # Base configurator
      class Base
        # Config variable
        @config = nil

        # initializer
        def initialize(config)
          @config = config
        end

        # Is with same name?
        def same?(name)
          self.class.name.eql?(name)
        end
      end

      # Default configurator
      class Default < ImpressCMSBox::Vagrant::Configurators::Base
        # Some providers configurators
        @configurators = []

        # initializtor
        def initialize(config)
          super config

          @configurators = [
            ImpressCMSBox::Vagrant::Configurators::HyperV.new(config),
            ImpressCMSBox::Vagrant::Configurators::VirtualBox.new(config)
          ]
        end

        # Provision
        # cd /srv/www/phpmyadmin
        # chown -R www-data ./
        # chgrp www-data ./
        # git pull
        # chown -R www-data ./
        # chgrp www-data ./
        # cd /srv/www/Memchaced-Dashboard
        # chown -R www-data ./
        # chgrp www-data ./
        # git pull
        # chown -R www-data ./
        # chgrp www-data ./
        def provision
          @config.vm.provision 'shell', inline: <<-SHELL
             sudo -u root bash -c 'cd /srv/www/impresscms && chown -R www-data ./ && chgrp www-data ./ &&  git pull && chown -R www-data ./ && chgrp www-data ./'
             if [ ![ -L "/srv/www/impresscms" && -d "/srv/www/impresscms" ] ]; then
               echo "ImpressCMS dir setup running..."
               sudo -u root bash -c 'rm -rf /vagrant/impresscms/'
               sudo -u root bash -c 'mv /srv/www/impresscms /vagrant/'
               sudo -u root bash -c 'ln -s /vagrant/impresscms /srv/www/impresscms'
             fi
          SHELL
        end

        # Basic configure
        def basic_configure(vmname, cpus, memory, gui)
          @configurators.each do |configurator|
            configurator.basic_configure vmname, cpus, memory, gui
          end
        end

        # Specific configure
        def specific_configure(provider, config)
          @configurators.each do |configurator|
            if configurator.same?(provider)
              configurator.specific_configure config
            end
          end
        end

        # Box name to use for this vagrant configuration
        def name(name)
          @config.vm.box = name
        end

        # Configure SSH
        def configure_ssh(private_key)
          @config.ssh.insert_key = true
          @config.ssh.pty = false
          @config.ssh.forward_x11 = false
          @config.ssh.forward_agent = false
          @config.ssh.private_key_path = File.dirname(private_key)
        end

        # Configure network
        def configure_network(ip)
          @config.vm.network 'private_network',
                             ip: ip
        end

        # Forward vars
        def forward_vars(vars)
          @config.ssh.forward_env = vars
        end

        # Automatically check for update for this box ?
        def check_for_update(check)
          @config.vm.box_check_update = check
        end

        # forward one port
        def forward_port(guest_port, host_port, protocol = 'tcp')
          @config.vm.network 'forwarded_port',
                             guest: guest_port,
                             host: host_port,
                             protocol: protocol,
                             auto_correct: true
        end

        # Forward ports
        def forward_ports(ports)
          ports.each do |pgroup|
            forward_port pgroup['guest'],
                         pgroup['host'],
                         Cval.enum(
                           pgroup,
                           'protocol',
                           'tcp',
                           %w(tcp udp)
                         )
          end
        end
      end

      # HyperV configurator
      class HyperV < ImpressCMSBox::Vagrant::Configurators::Base
        # Configure basic settings
        def basic_configure(vmname, cpus, memory, _gui)
          @config.vm.provider 'hyperv' do |v|
            v.vmname = vmname
            v.cpus = cpus
            v.memory = memory
          end
        end

        # Configure specific
        def specific_configure(cfg)
          if cfg.key?('smb')
            error 'HyperV provider needs defined smb options in config.yaml.'
          end
          ip = Cval.str(cfg['smb'], 'ip')
          password = Cval.str(cfg['smb'], 'pass')
          username = Cval.str(cfg['smb'], 'user')
          samba_configure ip, password, username
        end

        # Configure samba
        def samba_configure(ip, password, username)
          @config.vm.synced_folder '.', '/vagrant',
                                   id: 'vagrant',
                                   smb_host: ip,
                                   smb_password: password,
                                   smb_username: username,
                                   user: 'www-data',
                                   owner: 'www-data'
        end
      end

      # Virtualbox configurator
      class VirtualBox < ImpressCMSBox::Vagrant::Configurators::Base
        # Configure basic settings
        def basic_configure(vmname, cpus, memory, gui)
          config.vm.provider 'virtualbox' do |v|
            v.gui = gui
            v.vmname = vmname
            v.cpus = cpus
            v.memory = memory
          end
        end

        # Configure specific
        def specific_configure(cfg)
        end
      end
    end
  end

  # Main code
  class Main < ImpressCMSBox::BaseObject
    # Configuration
    @config = nil

    # Info
    @info = nil

    # Keys
    @keys = nil

    # Initializer
    def initialize
      @config = ImpressCMSBox::Config.read
      @info = ImpressCMSBox::Vagrant::Info.new
      @plugins = ImpressCMSBox::Vagrant::Plugins.new
      @keys = ImpressCMSBox::SSHkeyDetect.detect(@config)
      configure
    end

    def configure
      Vagrant.configure(@info.api_version) do |cfg|
        configurator = ImpressCMSBox::Configurator.new(cfg)
        use_configurator configurator
      end
    end

    def use_configurator(configurator)
      name = 'ImpressCMS/DevBox-Ubuntu'
      configurator.name name
      configurator.configure_network @config['ip']
      configurator.configure_ssh @keys.private
      configurator.forward_vars ['APP_ENV']
      configurator.check_for_update Cval.bool(@config, 'check_update', false)
      configurator.specific_configure @info.provider, @config
      _forward_ports configurator
      _basic_configure configurator, name
    end

    def _basic_configure(configurator, name)
      configurator.basic_configure Cval.str(@config, 'name', name),
                                   Cval.int(@config, 'cpus', 1),
                                   Cval.int(@config, 'memory', 512),
                                   Cval.bool(@config, 'gui', false)
    end

    def _forward_ports(configurator)
      if @config.key?('ports') && !@config.empty?
        configurator.forward_ports @config['ports']
      else
        error 'At least one port should be defined in config.yaml.'
      end
    end

    private :use_configurator,
            :configure,
            :_forward_ports
  end
end

ImpressCMSBox::Main.new
