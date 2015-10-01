# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "wmit/trusty64"

  # Sensu Server
  config.vm.define :sensu_server do |sensu_server_config|
    sensu_server_config.vm.provider "virtualbox" do |v|
      v.customize [
        "modifyvm", :id,
        "--name", "sensu_server",
        "--memory", "1024"
      ]
    end
    sensu_server_config.vm.box = "wmit/trusty64"
    sensu_server_config.vm.hostname = "sensu-server"
    config.vm.provision "shell", path: "./pre-puppet.sh"
    sensu_server_config.vm.provision "shell", path: "./pre-puppet.sh"
    sensu_server_config.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "hiera.yaml"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "sensu_server.pp"
      puppet.options = "--pluginsync"
    end
    sensu_server_config.vm.network :private_network, ip: "10.254.254.10"
    config.vm.provision "shell", path: "./post-puppet.sh"
  end

  # Sensu Client
  config.vm.define :sensu_client do |sensu_client_config|
    sensu_client_config.vm.provider "virtualbox" do |v|
      v.customize [
        "modifyvm", :id,
        "--name", "sensu_client",
        "--memory", "512"
      ]
    end
    sensu_client_config.vm.box = "wmit/trusty64"
    sensu_client_config.vm.hostname = "sensu-client"
    sensu_client_config.vm.provision "shell", path: "./pre-puppet.sh"
    sensu_client_config.vm.provision :puppet do |puppet|
      puppet.facter = {
        "sensu_server" => "10.254.254.10"
      }
      puppet.hiera_config_path = "hiera.yaml"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "sensu_client.pp"
      puppet.options = "--pluginsync"
    end
    sensu_client_config.vm.network :private_network, ip: "10.254.254.11"
    sensu_client_config.vm.provision "shell", path: "./post-puppet.sh"
  end

  # Web Server
  config.vm.define :web_server do |web_server_config|
    web_server_config.vm.provider "virtualbox" do |v|
      v.customize [
        "modifyvm", :id,
        "--name", "web_server",
        "--memory", "512"
      ]
    end
    web_server_config.vm.box = "wmit/trusty64"
    web_server_config.vm.hostname = "web-server"
    web_server_config.vm.provision "shell", path: "./pre-puppet.sh"
    web_server_config.vm.provision :puppet do |puppet|
      puppet.facter = {
        "sensu_server" => "10.254.254.10"
      }
      puppet.hiera_config_path = "hiera.yaml"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "web_server.pp"
      puppet.options = "--pluginsync"
    end
    web_server_config.vm.network :private_network, ip: "10.254.254.12"
    web_server_config.vm.provision "shell", path: "./post-puppet.sh"
  end

end
