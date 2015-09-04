Vagrant.configure("2") do |config|

#
# config type JASON
#
  # Load config JSON.
  config_json = JSON.parse(File.read("config.json"))

config.vm.provider "virtualbox" do |v|
  v.name = config_json["vm"]["name"]
  config.vm.box = "trusty"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
end

# config type YMAL
# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#
# Vagrant.configure(2) do |config|
# 
#  require 'yaml'
#  if File.exist?('./config.yml')
#    # Load config.yml
#    vconfig = YAML::load_file("./config.yml")
#    # Set base box.
#    config.vm.box = vconfig['vagrant_box']
#  end
#
#end

  # Prepare base box.
  config.vm.box = "trusty"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"

  # Configure networking.
  config.vm.network :private_network, ip: config_json["vm"]["ip"]

  # Configure forwarded ports.
  config.vm.network "forwarded_port", guest: 35729, host: 35729, protocol: "tcp", auto_correct: true
  config.vm.network "forwarded_port", guest: 8983, host: 8983, protocol: "tcp", auto_correct: true
  # User defined forwarded ports.
  config_json["vm"]["forwarded_ports"].each do |port|
    config.vm.network "forwarded_port", guest: port["guest_port"],
      host: port["host_port"], protocol: port["protocol"], auto_correct: true
  end

  # Customize provider.
  config.vm.provider :virtualbox do |vb|
    # RAM.
    vb.customize ["modifyvm", :id, "--memory", config_json["vm"]["memory"]]

    # Synced Folders.
    config_json["vm"]["synced_folders"].each do |folder|
      case folder["type"]
      when "nfs"
        config.vm.synced_folder folder["host_path"], folder["guest_path"], type: "nfs", id: "vagrant-root", :owner => "www-data", :group => "www-data"
        # This uses uid and gid of the user that started vagrant.
        config.nfs.map_uid = Process.uid
        config.nfs.map_gid = Process.gid
      else
        config.vm.synced_folder folder["host_path"], folder["guest_path"], id: "vagrant-root", :owner => "www-data", :group => "www-data"
      end
    end
  end
  
  # Enable vagrant-hostsupdater support, if the plugin is installed
  # see https://github.com/cogitatio/vagrant-hostsupdater for details
  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.vm.host_name = config_json["vm"]["url"]
    config.hostsupdater.aliases = []

    config_json["config_sites"]["sites"].each do |index, site|
        config.hostsupdater.aliases.push(site["vhost"]["url"])
        if site["vhost"]["alias"]
          site["vhost"]["alias"].each do |alias_url|
            config.hostsupdater.aliases.push(alias_url)
          end
        end
    end
  end
  
  config.vm.provision :shell, :path => "provision_drupal.sh"
  
end