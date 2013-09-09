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

OS = UBUNTU

options = {
  :nodes => 1,
  :base_ip => "33.33.33",
  :ip_increment => 10,
  :cores => 1,
  :memory => 1536,
  :riak_listen_address => "127.0.0.1",
  :stanchion_listen_address => "0.0.0.0",
  :riak_cs_root_host => "s3.amazonaws.com",
  :riak_cs_listen_address => "0.0.0.0",
  :riak_cs_rewrite_module => "riak_cs_s3_rewrite",
  :riak_cs_auth_module => "riak_cs_s3_auth"
}

CONF_FILE = Pathname.new("vagrant-overrides.conf")

override_options = CONF_FILE.exist? ? Hash[*File.read(CONF_FILE).split(/[= \n]+/)] : {}
override_options.each { |key, value| options[key.to_sym] = value unless key.start_with?("#") }

Vagrant.configure("2") do |cluster|
  # Ensure latest version of Chef is installed.
  cluster.omnibus.chef_version = :latest

  # Utilize the Berkshelf plugin to resolve cookbook dependencies.
  cluster.berkshelf.enabled = true

  (1..options[:nodes].to_i).each do |index|
    last_octet = index * options[:ip_increment].to_i

    cluster.vm.define "riak#{index}".to_sym do |config|
      # Configure the VM and operating system.
      config.vm.box = OS[:box]
      config.vm.box_url = OS[:url]
      config.vm.provider(:virtualbox) { |v| v.customize [ "modifyvm", :id, "--memory", options[:memory].to_i, "--cpus", options[:cores].to_i ] }

      # Setup the network and additional file shares.
      if index == 1
        [ 8000, 8080, 8085, 8087, 8098 ].each do |port|
          config.vm.network :forwarded_port, guest: port, host: port
        end
      end

      config.vm.hostname = "riak#{index}"
      config.vm.network :private_network, ip: "#{options[:base_ip]}.#{last_octet}"

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
        chef.add_role "riak_cs"
        chef.add_role "stanchion" if index == 1

        if !ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? && index == 1
          chef.add_recipe "riak-cs::control"

          if options[:riak_cs_rewrite_module] == "riak_cs_s3_rewrite" &&
            options[:riak_cs_auth_module] == "riak_cs_s3_auth"
            chef.add_recipe "riak-cs-create-admin-user"
          end
        end

        chef.json = {
          "riak" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak@#{options[:base_ip]}.#{last_octet}"
            },
            "config" => {
              "riak_api" => {
                "pb" =>
                  { "__string_#{options[:riak_listen_address]}" => 8087 }
              },
              "riak_core" => {
                "http" =>
                  { "__string_#{options[:riak_listen_address]}" => 8098 }
              }
            }
          },
          "riak_cs" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak-cs@#{options[:base_ip]}.#{last_octet}"
            },
            "config" => {
              "riak_cs" => {
                "riak_ip" => "__string_#{options[:riak_listen_address]}",
                "stanchion_ip" => "__string_#{options[:stanchion_listen_address]}",
                "anonymous_user_creation" => ((ENV["RIAK_CS_CREATE_ADMIN_USER"].nil? || index != 1) ? false : true),
                "cs_root_host" => "__string_#{options[:riak_cs_root_host]}",
                "cs_ip" => "__string_#{options[:riak_cs_listen_address]}",
                "rewrite_module" => options[:riak_cs_rewrite_module],
                "auth_module" => options[:riak_cs_auth_module]
              }
            }
          },
          "stanchion" => {
            "args" => {
              "+S" => 1,
              "-name" => "stanchion@#{options[:base_ip]}.#{last_octet}"
            },
            "config" => {
              "stanchion" => {
                "riak_ip" => "__string_#{options[:riak_listen_address]}",
                "stanchion_ip" => "__string_#{options[:stanchion_listen_address]}"
              }
            }
          },
          "riak_cs_control" => {
            "args" => {
              "+S" => 1,
              "-name" => "riak-cs-control@#{options[:base_ip]}.#{last_octet}"
            }
          }
        }
      end

      if options[:riak_cs_rewrite_module] == "riak_cs_oos_rewrite" &&
        options[:riak_cs_auth_module] == "riak_cs_keystone_auth"
        if OS == UBUNTU
          config.vm.provision "shell", path: "bin/setup-keystone-ubuntu.sh"
        elsif OS == CENTOS
          config.vm.provision "shell", path: "bin/setup-keystone-centos.sh"
        end
      end
    end
  end
end
