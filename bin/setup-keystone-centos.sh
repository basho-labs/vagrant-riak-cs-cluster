#! /bin/bash

set -e

# Install dependencies
sudo yum install -y make gcc gcc-c++ kernel-devel git vim curl python-pip python-devel \
  libevent-devel libxml2-devel libxml2-devel libxslt-devel

# Install jq
wget -q http://stedolan.github.io/jq/download/linux64/jq
chmod a+x jq
sudo mv jq /usr/local/bin

# Clone the Keystone repository
git clone https://github.com/openstack/keystone.git
cd keystone
git checkout grizzly-2

# Install more dependencies
sudo pip install -r tools/pip-requires

# Setup the Keystone log and configuration files
mkdir -p ./log/keystone/
touch ./log/keystone/keystone.log
cp /vagrant/etc/default_catalog.templates ./etc/
cp /vagrant/etc/keystone.conf ./etc/
sudo chown -R vagrant:vagrant .

# Setup the database and launch Keystone
su -c 'cd keystone && ./bin/keystone-manage db_sync' - vagrant
su -c 'cd keystone && ./bin/keystone-all --config-file $HOME/keystone/etc/keystone.conf -d &' - vagrant

sleep 5

# Setup Keystone
export OS_SERVICE_TOKEN="ADMIN"
export OS_SERVICE_ENDPOINT="http://localhost:35357/v2.0"
export OS_IDENTITY_API_VERSION="2.0"
export OS_AUTH_URL="http://localhost:5000/v2.0"
export OS_USERNAME="test"
export OS_PASSWORD="test"
export OS_TENANT_NAME="test"

TENANT_ID=$(keystone tenant-create --name test | grep "id" | awk -F'|' '{gsub(/[ \t]+/, "", $3); print $3 }')
USER_ID=$(keystone user-create --name test --pass test --email test@test.com --tenant-id $TENANT_ID --enabled true | \
  grep "id" | awk -F'|' '{gsub(/[ \t]+/, "", $3); print $3 }')
ROLE_ID=$(keystone role-create --name swiftoperator | grep "id" | awk -F'|' '{gsub(/[ \t]+/, "", $3); print $3 }')
keystone user-role-add --user-id $USER_ID --role-id $ROLE_ID --tenant-id $TENANT_ID
keystone ec2-credentials-create --user_id $USER_ID --tenant_id $TENANT_ID

echo "Token & Public URL:\n\n"

curl -s -d '{"auth": {"tenantName": "test", "passwordCredentials": {"username": "test", "password": "test"}}}' -H 'Content-type: application/json' http://localhost:5000/v2.0/tokens | /usr/local/bin/jq '.access.token.id, .access.serviceCatalog[0].endpoints[0].publicURL'
