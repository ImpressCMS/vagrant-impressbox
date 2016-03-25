module Impressbox
  PATH = __dir__
  def self.app_path
    File.expand_path('..', Impressbox::PATH)
  end  
  autoload :Keys, File.join(PATH, 'keys.rb')
  autoload :Cval, File.join(PATH, 'cval.rb')
  module Objects
    PATH = File.join(Impressbox::PATH, 'objects')
    autoload :Base, File.join(PATH, 'base.rb')
    autoload :Config, File.join(PATH, 'config.rb')
    autoload :Main, File.join(PATH, 'main.rb')
    autoload :SSHkeyDetect, File.join(PATH, 'ssh_key_detect.rb')
  end
  module Vagrant
    PATH = File.join(Impressbox::PATH, 'vagrant')
    module Configurators
      path = File.join(Impressbox::Vagrant::PATH, 'configurators')
      autoload :Base, File.join(path, 'base.rb')
      autoload :Default, File.join(path, 'default.rb')
      autoload :HyperV, File.join(path, 'hyperv.rb')
      autoload :VirtualBox, File.join(path, 'virtualbox.rb')
    end
    autoload :Info, File.join(PATH, 'info.rb')
    autoload :Plugins, File.join(PATH, 'plugins.rb')
  end
end

Impressbox::Objects::Main.new Vagrant
