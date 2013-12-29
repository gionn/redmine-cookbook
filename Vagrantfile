# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.hostname = "redmine"
  config.vm.box = "opscode-precise-vbox"

  config.vm.network :private_network, ip: "33.33.33.10"

  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--memory", "768"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    override.vm.box = "opscode-precise-vbox"
    override.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "opscode-precise-lxc"
    override.vm.box_url = "https://dl.dropboxusercontent.com/u/13510779/vagrant-lxc-precise-amd64-2013-10-23.box"
  end

  config.berkshelf.enabled = true
  config.omnibus.chef_version = "11.6.2"
  config.cache.enable :apt

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => "iloverandompasswordsbutthiswilldo",
        :server_repl_password => "iloverandompasswordsbutthiswilldo",
        :server_debian_password => "iloverandompasswordsbutthiswilldo"
      },
    }

    chef.run_list = [
        "recipe[redmine::mysql]",
        "recipe[redmine::ruby]",
        "recipe[redmine::redmine]"
    ]
  end
end
