# -*- mode: ruby -*-
# vi: set ft=ruby :

CENTOS = {
  sudo_group: "wheel",
  box: "opscode-centos-6.4",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.4_chef-11.4.4.box"
}
UBUNTU = {
  sudo_group: "sudo",
  box: "opscode-ubuntu-12.04",
  url: "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.4.box"
}

NODES         = 1
OS            = UBUNTU
BASE_IP       = "33.33.33"
IP_INCREMENT  = 10

Vagrant.configure("2") do |cluster|
  (1..NODES).each do |index|
    last_octet = index * IP_INCREMENT

    cluster.vm.define "riak#{index}".to_sym do |config|
      # Configure the VM and operating system.
      config.vm.box = OS[:box]
      config.vm.box_url = OS[:url]
      config.vm.provider(:virtualbox) { |v| v.customize ["modifyvm", :id, "--memory", 1536] }

      # Setup the network and additional file shares.
      if index == 1
        config.vm.network :forwarded_port, guest: 8000, host: 8000
        config.vm.network :forwarded_port, guest: 8080, host: 8080
        config.vm.network :forwarded_port, guest: 8085, host: 8085
        config.vm.network :forwarded_port, guest: 8087, host: 8087
      end

      config.vm.hostname = "riak#{index}"
      config.vm.network :private_network, ip: "#{BASE_IP}.#{last_octet}"
      config.vm.synced_folder "lib/", "/tmp/vagrant-chef-1/lib"

      # Hack for Berkshelf until the following bug is resolved:
      # https://github.com/RiotGames/berkshelf-vagrant/issues/4
      config.vm.provision :shell, :inline => <<-SCRIPT.gsub(/^ {8}/, '')
        #!/bin/sh
        if [ -x /usr/bin/apt-get ]; then
          sudo apt-get update
          sudo apt-get install -qq -y git libxslt1-dev
        else
          sudo yum update
          sudo yum install -q -y git libxslt-devel
        fi
        if [ ! -x /opt/chef/embedded/bin/berks ]; then
          echo "Installing berkshelf"
          sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc --quiet
        fi
        echo "Berkshelf: Installing cookbooks"
        sudo /opt/chef/embedded/bin/berks install -b /vagrant/Berksfile -p /tmp/vagrant-chef-1/chef-solo-1/cookbooks
        sudo mv /tmp/vagrant-chef-1/chef-solo-1/cookbooks/`ls -1 /tmp/vagrant-chef-1/chef-solo-1/cookbooks/`/* /tmp/vagrant-chef-1/chef-solo-1/cookbooks
      SCRIPT

      # Provision using Chef.
      config.vm.provision :chef_solo do |chef|
        chef.roles_path = "roles"
        chef.cookbooks_path = "cookbooks"

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

        if !ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? && index == 1
          chef.add_recipe "riak-cs::control"
          chef.add_recipe "riak-cs-create-admin-user"
        end

        chef.json = {
          "authorization" => {
            "sudo" => {
              "groups" => [ OS[:sudo_group] ],
            }
          },
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
    end
  end
end
