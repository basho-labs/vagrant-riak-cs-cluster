# Vagrant Riak CS Cluster

This is a Vagrant project powered by Chef to bring up a local [Riak
CS](https://github.com/basho/riak_cs) cluster. Each node can run either
`Ubuntu 12.04` or `CentOS 6.5` 64-bit with `1024MB` of RAM by default.

## Description 

This repository is **community supported**. We both appreciate and need your
contribution to keep it stable. For more on how to contribute,
[take a look at the contribution process](#contribution).

Thank you for being part of the community! We love you for it.

## Configuration

### Install Vagrant

Download and install Vagrant via the
[Vagrant installer](http://downloads.vagrantup.com/).

### Install Vagrant plugins

``` bash
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-cachier (Use RIAK_CS_USE_CACHE to enable)
```

### Clone repository

``` bash
$ git clone https://github.com/basho-labs/vagrant-riak-cs-cluster.git
$ cd vagrant-riak-cs-cluster
```

### Launch cluster

``` bash
$ RIAK_CS_USE_CACHE=1 RIAK_CS_CREATE_ADMIN_USER=1 vagrant up
```

### Environmental variables

- `RIAK_CS_CREATE_ADMIN_USER` – A flag signaling whether you want an
  administrative user for Riak CS to be created for you (default: `false`)
- `RIAK_CS_USE_CACHE` – Whether you want to allow Vagrant to use the
  [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) plugin or not
  (default: `false`)

### Test cluster

``` bash
$ s3cmd -c ~/.s3cfgfasttrack --configure
```

There are 4 default settings you should change:

* **Access Key** - Replace with value next to `Riak CS Key` in the Chef
  provisioning output.
* **Secret Key** - Replace with value next to `Riak CS Secret` in the Chef
  provisioning output.
* **Proxy Server**: `localhost`
* **Proxy Port**: `8080`

In addition, change `signature_v2 = False` to `signature_v2 = True`; `s3cmd`
uses AWS v4 authentication, whereas Riak CS does not support this yet.  See also
[issue 897](https://github.com/basho/riak_cs/issues/897).

``` bash
$ s3cmd -c ~/.s3cfgfasttrack mb s3://test-bucket
```

### Customize cluster

By default, the cluster will be built using the following options:

```
nodes=1
base_ip=33.33.33
ip_increment=10
cores=1
memory=1024
riak_listen_address=127.0.0.1
stanchion_listen_address=33.33.33.10
riak_cs_root_host=s3.amazonaws.com
riak_cs_listen_address=0.0.0.0
riak_cs_rewrite_module=riak_cs_s3_rewrite
riak_cs_auth_module=>riak_cs_s3_auth
```

These defaults can be overridden by creating a `vagrant-overrides.conf` file
in the same directory as the Vagrantfile in the form of `key=value`.

## Riak CS Control

[Riak CS Control](https://github.com/basho/riak_cs_control) is a standalone user
management application for Riak CS. It provides a user interface for filtering,
disabling, creating and managing users in a Riak CS Cluster.

Navigate to `http://localhost:8000` in your web browser.

## Vagrant boxes

The Vagrant boxes used in this project were created by
[Packer](http://www.packer.io/). To view the Packer templates, please follow
the links below:

* [opscode-centos-6.5](https://github.com/opscode/bento/blob/master/packer/centos-6.5-x86_64.json)
* [opscode-ubuntu-12.04](https://github.com/opscode/bento/blob/master/packer/ubuntu-12.04-amd64.json)

## Contribution

Basho Labs repos survive because of community contribution. Here’s how to get started.

* Fork the appropriate sub-projects that are affected by your change
* Create a topic branch for your change and checkout that branch
     `git checkout -b some-topic-branch`
* Make your changes and run the test suite if one is provided (see below)
* Commit your changes and push them to your fork
* Open a pull request with a descriptive title
* Maintainers will review your pull request, suggest changes, and merge it when it’s ready and/or offer feedback
* To report a bug or issue, please open a new issue against this repository

You can [read the full guidelines for bug reporting and code contributions](http://docs.basho.com/riak/latest/community/bugs/) on the Riak Docs. And **thank you!** Your contribution is incredible important to us.

### Maintainers
* This repo needs one! Open an issue if you'd like to become one
