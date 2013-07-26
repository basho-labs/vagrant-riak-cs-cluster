# -*- mode: ruby -*-
# vi: set ft=ruby :

CENTOS = {
  box: "opscode-centos-6.4",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box"
}
UBUNTU = {
  box: "opscode-ubuntu-12.04",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
}

NODES         = 1
OS            = UBUNTU
BASE_IP       = "33.33.33"
IP_INCREMENT  = 10

Vagrant.configure("2") do |cluster|
  # Ensure latest version of Chef is installed.
  cluster.omnibus.chef_version = :latest

  # Utilize the Berkshelf plugin to resolve cookbook dependencies.
  cluster.berkshelf.enabled = true

  (1..NODES).each do |index|
    last_octet = index * IP_INCREMENT

    cluster.vm.define "riak#{index}".to_sym do |config|
      # Configure the VM and operating system.
      config.vm.box = OS[:box]
      config.vm.box_url = OS[:url]
      config.vm.provider(:virtualbox) { |v| v.customize ["modifyvm", :id, "--memory", 1536] }

      # Setup the network and additional file shares.
      if index == 1
        [ 8000, 8080, 8085, 8087, 8098 ].each do |port|
          config.vm.network :forwarded_port, guest: port, host: port
        end
      end

      config.vm.hostname = "riak#{index}"
      config.vm.network :private_network, ip: "#{BASE_IP}.#{last_octet}"

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
        chef.add_role "riak_cs"
        chef.add_role "riak"
        chef.add_role "stanchion" if index == 1

        if !ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? && index == 1
          chef.add_recipe "riak-cs::control"
          chef.add_recipe "riak-cs-create-admin-user"
        end

        chef.json = {
          "riak" => {
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
                "anonymous_user_creation" => ((ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? || index != 1) ? false : true)
              }
            }
          },
          "stanchion" => {
            "args" => {
              "+S" => 1,
              "-name" => "stanchion@33.33.33.#{last_octet}"
            }
          },
          "riak_cs_control" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak-cs-control@33.33.33.#{last_octet}"
            }
          }
        }
      end

      config.vm.provision :shell, :inline => "sudo service riak-cs start"
    end
  end
end
