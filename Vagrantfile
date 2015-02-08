# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  # pakeiskite reikšmę į chef/centos-7.0 jei labiau norisi naudotis virtualbox arba vmware virtualia mašina
  # pagal nutylėjimą naudojama Hyper-V (Windows 8.1)
  config.vm.box = "serveit/centos-7"

  config.vm.network :private_network, ip: "192.168.21.1"
  config.vm.synced_folder "gameslt", "/home/gameslt"

  config.vm.provision :shell, path: "bootstrap.sh"

end
