# Vagrant Riak CS Cluster

This is a Vagrant project powered by Chef to bring up a local Riak CS cluster.
Each node can run either `Ubuntu 12.04` or `CentOS 6.3` 32-bit with `1024MB`
of RAM by default. If you want to tune the OS or node/memory count, you'll
have to edit the `Vagrantfile` directly.

## Configuration

### Install Vagrant

Download and install Vagrant via the
[Vagrant installer](http://downloads.vagrantup.com/tags/v1.0.7).

**Note**: It is necessary, at present, to install Vagrant 1.0.7 due to a
compatibility issue.

### Install cookbooks

``` bash
$ gem install bundler
$ bundle install
$ bundle exec berks install
```

### Launch cluster

``` bash
$ RIAK_CS_CREATE_ADMIN_USER=1 vagrant up
```

### Create admin user

``` bash
$ curl -H 'Content-Type: application/json'                  \
       -X POST http://localhost:8080/riak-cs/user           \
       --data '{"email":"admin@admin.com", "name":"admin"}'
$ RIAK_CS_ADMIN_KEY="<ADMIN_KEY>" RIAK_CS_SECRET_KEY="<SECRET_KEY>" vagrant provision
```

## Accessing individual nodes

Each node in the cluster is named in the form `riakN` — where `N` is a number
between `1` and the number of nodes defined for the cluster.

``` bash
$ vagrant ssh riak1
```

## Vagrant boxes

The Vagrant boxes used in this project were created by
[Veewee](https://github.com/jedi4ever/veewee/). To view the Veewee definitions,
please follow the links below:

* [opscode-centos-6.3](https://github.com/opscode/bento/tree/master/definitions/centos-6.3-i386)
* [opscode-ubuntu-12.04](https://github.com/opscode/bento/tree/master/definitions/ubuntu-12.04-i386)

## Erlang template helper

In order to set the appropriate Erlang data types for attributes, please use
the following methods provided by `erlang_template_helper`:

* `to_erl_string`
* `to_erl_binary`
* `to_erl_tuple`
* `to_erl_list`
