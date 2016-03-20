# -*- mode: ruby -*-
# vi: set ft=ruby :

# Config values parsing
class Cval
  def self.bool(config, name, default)
    return default unless config.key?(name)
    return true if config[name]
    false
  end

  def self.str(config, name, default)
    return config[name].to_s if config.key?(name)
    default
  end

  def self.int(config, name, default)
    return config[name].to_s.to_i if config.key?(name)
    default
  end

  def self.enum(config, name, default, possible)
    value = str(config, name, default)
    return value if possible.include?(value)
    default
  end
end

# here goes all functions that can be triggered
# for any delivered class
class BaseObject
  def self.error(msg)
    raise Vagrant::Errors::VagrantError.new, "#{msg}\n"
  end
end

# Keys handling class
class Keys
  @public = nil
  @private = nil

  def initialize(private_key = nil, public_key = nil)
    @public = public_key
    @private = private_key
  end

  def empty?
    @private.nil? && @public.nil?
  end

  def print
    print_key 'Public', @public
    print_key 'Private', @private
  end

  def print_key(name, value)
    if value.nil?
      print name + ' key was undetected'
    else
      print name + ' key autotected to ' + value.to_s + "\n"
    end
  end

  private :print_key
end

# SSH key detect
class SSHkeyDetect < BaseObject
  def initialize(config)
    @keys = Keys.new
    @config = config
    try_config if @config.key?('keys')
    try_filesystem unless @keys.empty?
  end

  def try_config
    return unless @config.key?('keys')
    @keys = @detect_ssh_keys_from_config
    err_msg = validate_from_config ssh_keys
    error err_msg unless err_msg.nil?
  end

  def try_filesystem
    @keys = @detect_ssh_keys_from_filesystem
    if @keys.empty?
      error "Can't autodetect SSH keys. Please specify in config.yaml."
    end
    @keys.print
  end

  def validate_from_config(keys)
    return nil if keys.empty?
    unless keys['private'].nil? || (!File.exist? @keys['private'])
      return "Private key defined in config.yaml can't be found."
    end
    unless File.exist? @keys['public']
      return "Public key defined in config.yaml can't be found."
    end
  end

  # Try detect SSH keys by using only a config
  def detect_ssh_keys_from_config
    private_defined = @config['keys'].key?('private')
    public_defined = @config['keys'].key?('public')

    return Keys.new unless private_defined && public_defined

    if private_defined && public_defined
      return Keys.new(
        @config['keys']['private'],
        @config['keys']['public']
      )
    elsif private_defined
      return Keys.new(
        @config['keys']['private'],
        @config['keys']['public'] + '.pub'
      )
    end
    Keys.new(
      private_filename_from_public(@config['keys']['private']),
      @config['keys']['public']
    )
  end

  # Try detect SSH keys by using local filestystem
  def detect_ssh_keys_from_filesystem
    @ssh_keys_search_paths.each do |dir|
      keys = iterate_dir_fs(dir)
      return keys unless keys.empty?
    end
    Keys.new
  end

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

  private :detect_ssh_keys_from_config,
          :detect_ssh_keys_from_filesystem
end

# Main code
class ImpressCMSBox < BaseObject
  # Vagrant file api version
  VAGRANTFILE_API_VERSION ||= '2'.freeze
  # Defines required vagrant plugins
  VAGRANT_PLUGINS = [
    'vagrant-hostmanager'
  ].freeze

  def initialize
    @provider = @detect_provider
    @config_file = @detect_yaml_config
    error 'config.yaml not found.' if @config_file.nil?
    @load_required_vagrant_plugins if ARGV.include?('up')
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

  # Detecting provider
  def detect_provider
    if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
      return (ARGV[1].split('=')[1] || ARGV[2])
    end
    (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
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

  # Loads all plugins defined in VAGRANT_PLUGINS constant
  def load_required_vagrant_plugins
    needed_reboot = false
    VAGRANT_PLUGINS.each do |plugin|
      unless Vagrant.has_plugin?(plugin)
        system 'vagrant plugin install ' + plugin
        needed_reboot = true
      end
    end
    return unless needed_reboot
    system 'vagrant up'
    exit true
  end

  private :detect_provider,
          :detect_yaml_config,
          :load_required_vagrant_plugins
end

# Here goes real stuff!
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Box name to use for this vagrant configuration
  config.vm.box = 'ImpressCMS/DevBox-Ubuntu'

  # Configure network
  config.vm.network 'private_network',
                    ip: @config['ip']

  # Automatically check for update for this box ?
  config.vm.box_check_update = Cval.bool(@config, 'check_update', false)

  # SSH keys
  config.ssh.insert_key = true
  config.ssh.pty = false
  config.ssh.forward_x11 = false
  config.ssh.forward_agent = false
  config.ssh.private_key_path = File.dirname(private_key)

  # Forvard vars
  config.ssh.forward_env = ['APP_ENV']

  # Configure ports
  if @config.key?('ports') && !@config.empty?
    @config['ports'].each do |pgroup|
      config.vm.network 'forwarded_port',
                        guest: pgroup['guest'],
                        host: pgroup['host'],
                        protocol: Cval.enum(
                          pgroup,
                          'protocol',
                          'tcp',
                          %w(tcp udp)
                        ),
                        auto_correct: true
    end
  else
    error 'At least one port should be defined in config.yaml.'
  end

  # Configure virtual box
  config.vm.provider 'virtualbox' do |v|
    v.gui = Cval.bool(@config, 'gui', false)
    v.name = Cval.str(@config, 'name', config.vm.box)
    v.cpus = Cval.int(@config, 'cpus', 1)
    v.memory = Cval.int(@config, 'memory', 512)
  end

  # Configure hyperv
  config.vm.provider 'hyperv' do |v|
    v.vmname = Cval.str(@config, 'name', config.vm.box)
    v.cpus = Cval.int(@config, 'cpus', 1)
    v.memory = Cval.int(@config, 'memory', 512)
  end

  # Setup hyperv (if we use this system)
  if provider == 'hyperv'

    if @config.key?('smb')
      error 'HyperV provider needs defined smb options in config.yaml.'
    end

    config.vm.synced_folder '.', '/vagrant',
                            id: 'vagrant',
                            smb_host: Cval.str(
                              @config['smb'],
                              'ip',
                              nil
                            ),
                            smb_password: Cval.str(
                              @config['smb'],
                              'pass',
                              nil
                            ),
                            smb_username: Cval.str(
                              @config['smb'],
                              'user',
                              nil
                            ),
                            user: 'www-data',
                            owner: 'www-data'

  end

  # Profision config
  config.vm.provision 'shell', inline: <<-SHELL
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
