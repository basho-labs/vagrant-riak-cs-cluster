# -*- mode: ruby -*-
# vi: set ft=ruby :

$LOAD_PATH.unshift("lib") unless $LOAD_PATH.include?("lib")

require "berkshelf/vagrant"
require "erlang_template_helper"

CENTOS = {
  sudo_group: "wheel",
  box: "opscode-centos-6.3",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box"
}
UBUNTU = {
  sudo_group: "sudo",
  box: "opscode-ubuntu-12.04",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.2.0.box"
}

NODES         = 1
OS            = UBUNTU
BASE_IP       = "33.33.33"
IP_INCREMENT  = 10

Vagrant::Config.run do |cluster|
  (1..NODES).each do |index|
    last_octet = index * IP_INCREMENT

    cluster.vm.define "riak#{index}".to_sym do |config|
      # Auto-update VirtualBox extensions when out-of-date.
      config.vbguest.auto_update = false

      # Configure the VM and operating system.
      config.vm.customize ["modifyvm", :id, "--memory", 1024]
      config.vm.box = OS[:box]
      config.vm.box_url = OS[:url]

      # Setup the network and additional file shares.
      if index == 1
        config.vm.forward_port 8080, 8080
        config.vm.forward_port 8085, 8085
        config.vm.forward_port 8087, 8087
      end

      config.vm.host_name = "riak#{index}"
      config.vm.network :hostonly, "#{BASE_IP}.#{last_octet}"
      config.vm.share_folder "lib", "/tmp/vagrant-chef-1/lib", "lib"

      # Provision using Chef.
      config.vm.provision :chef_solo do |chef|
        chef.roles_path = "roles"

        if config.vm.box =~ /ubuntu/
          chef.add_recipe "apt"
        else
          chef.add_recipe "yum"
          chef.add_recipe "yum::epel"
        end

        chef.add_role "base"
        chef.add_role "riak"
        chef.add_role "stanchion" if index == 1
        chef.add_role "riak_cs"

        chef.json = {
          "authorization" => {
            "sudo" => {
              "groups" => [ OS[:sudo_group] ],
            }
          },
          "riak_eds" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak@33.33.33.#{last_octet}"
            }
          },
          "riak_cs" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak-cs@33.33.33.#{last_octet}"
            },
            "config" => {
              "riak_cs" => {
                "anonymous_user_creation" => (ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? ? false : true),
                "admin_key" => (ENV["RIAK_CS_ADMIN_KEY"].nil? ? "admin-key" : ENV["RIAK_CS_ADMIN_KEY"]).to_erl_string,
                "admin_secret" => (ENV["RIAK_CS_SECRET_KEY"].nil? ? "admin-secret" : ENV["RIAK_CS_SECRET_KEY"]).to_erl_string
              }
            }
          },
          "stanchion" => {
            "args" => {
              "+S" => 1,
              "-name" => "stanchion@33.33.33.#{last_octet}"
            },
            "config" => {
              "stanchion" => {
                "admin_key" => (ENV["RIAK_CS_ADMIN_KEY"].nil? ? "admin-key" : ENV["RIAK_CS_ADMIN_KEY"]).to_erl_string,
                "admin_secret" => (ENV["RIAK_CS_SECRET_KEY"].nil? ? "admin-secret" : ENV["RIAK_CS_SECRET_KEY"]).to_erl_string
              }
            }
          }
        }
      end
    end
  end
end
