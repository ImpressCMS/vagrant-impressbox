# -*- mode: ruby -*-
# vi: set ft=ruby :

# Error triggering with less code
def trigger_error(msg)
  raise Vagrant::Errors::VagrantError.new, "#{msg}\n"
end

# Vagrant file api version
VAGRANTFILE_API_VERSION ||= '2'.freeze

# Detecting provider
provider = if ARGV[1] && (ARGV[1].split('=')[0] == '--provider' || ARGV[2])
             (ARGV[1].split('=')[1] || ARGV[2])
           else
             (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
           end

# Detect config.yaml location
if File.exist? File.join(__dir__, 'config.yaml')
  cfg_file = File.join(__dir__, 'config.yaml')
elsif File.exist? File.join(ENV['vbox_config_path'], 'config.yaml')
  cfg_file = File.join(ENV['vbox_config_path'], 'config.yaml')
else
  trigger_error 'config.yaml not found.'
end

# Install vagrant-hostmanager plugin if needed
unless Vagrant.has_plugin?('vagrant-hostmanager')
  system 'vagrant plugin install vagrant-hostmanager'
  system 'vagrant up'
  exit true
end

# Loads required libraries
require 'yaml'

# Load and parse config.yaml
yaml_cfg = begin
  YAML.load	File.open(cfg_file)
rescue ArgumentError => e
  trigger_error "Could not parse YAML: #{e.message}"
end

# Config parsing
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

# Detect SSH keys
if @yaml_cfg.key?('keys')
  if yaml_cfg['keys'].key?('private') && yaml_cfg['keys'].key?('public')
    private_key = yaml_cfg['keys']['private']
    public_key = yaml_cfg['keys']['public']
    unless File.exist? private_key
      trigger_error "Private key defined in config.yaml can't be found."
    end
    unless File.exist? public_key
      trigger_error "Public key defined in config.yaml can't be found."
    end
  elsif yaml_cfg['keys'].key?('private')
    private_key = yaml_cfg['keys']['private']
    public_key = yaml_cfg['keys']['public'] + '.pub'
    unless File.exist? private_key
      trigger_error "Private key defined in config.yaml can't be found."
    end
    unless File.exist? public_key
      trigger_error "Can't find public key for defined in config private key."
    end
  elsif yaml_cfg['keys'].key?('public')
    private_key = File.join(
      File.dirname(
        yaml_cfg['keys']['private'],
        File.basename(
          yaml_cfg['keys']['private'],
          '.pub'
        )
      )
    )
    public_key = yaml_cfg['keys']['public']
    unless File.exist? private_key
      trigger_error "Can't find private key for defined in config public key."
    end
    unless File.exist? public_key
      trigger_error "Public key defined in config.yaml can't be found."
    end
  end
end

if !defined?(private_key) || private_key.nil?
  [
    File.join(__dir__, '.ssh'),
    File.join(__dir__, 'ssh'),
    File.join(__dir__, 'keys'),
    File.join(Dir.home, '.ssh'),
    File.join(Dir.home, 'keys')
  ].each do |dir|
    next unless Dir.exist?(dir)

    Dir.entries(dir).each do |entry|
      entry = File.join(dir, entry)
      next unless File.file?(entry)
      next unless File.extname(entry).eql?('.pub')

      next unless File.exist?(File.join(dir, File.basename(entry, '.pub')))

      private_key = File.join(dir, File.basename(entry, '.pub'))
      public_key = entry

      print "Private key autotected to #{private_key}\n"
      print "Public key autotected to #{public_key}\n"

      break
    end

    break if defined? private_key
  end

  if !defined?(private_key) || private_key.nil?
    trigger_error "Can't autodetect SSH keys. Please specify in config.yaml."
  end
end

# Here goes real stuff!
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Box name to use for this vagrant configuration
  config.vm.box = 'ImpressCMS/DevBox-Ubuntu'

  # Configure network
  config.vm.network 'private_network',
                    ip: yaml_cfg['ip']

  # Automatically check for update for this box ?
  config.vm.box_check_update = Cval.bool(yaml_cfg, 'check_update', false)

  # SSH keys
  config.ssh.insert_key = true
  config.ssh.pty = false
  config.ssh.forward_x11 = false
  config.ssh.forward_agent = false
  config.ssh.private_key_path = File.dirname(private_key)

  # Forvard vars
  config.ssh.forward_env = ['APP_ENV']

  # Configure ports
  if yaml_cfg.key?('ports') && !yaml_cfg.empty?
    yaml_cfg['ports'].each do |pgroup|
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
    trigger_error 'At least one port should be defined in config.yaml.'
  end

  # Configure virtual box
  config.vm.provider 'virtualbox' do |v|
    v.gui = Cval.bool(yaml_cfg, 'gui', false)
    v.name = Cval.str(yaml_cfg, 'name', config.vm.box)
    v.cpus = Cval.int(yaml_cfg, 'cpus', 1)
    v.memory = Cval.int(yaml_cfg, 'memory', 512)
  end

  # Configure hyperv
  config.vm.provider 'hyperv' do |v|
    v.vmname = Cval.str(yaml_cfg, 'name', config.vm.box)
    v.cpus = Cval.int(yaml_cfg, 'cpus', 1)
    v.memory = Cval.int(yaml_cfg, 'memory', 512)
  end

  # Setup hyperv (if we use this system)
  if provider == 'hyperv'

    if yaml_cfg.key?('smb')
      trigger_error 'HyperV provider needs defined smb options in config.yaml.'
    end

    config.vm.synced_folder '.', '/vagrant',
                            id: 'vagrant',
                            smb_host: Cval.str(
                              yaml_cfg['smb'],
                              'ip',
                              nil
                            ),
                            smb_password: Cval.str(
                              yaml_cfg['smb'],
                              'pass',
                              nil
                            ),
                            smb_username: Cval.str(
                              yaml_cfg['smb'],
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
