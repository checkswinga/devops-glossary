Centos 7 Openshift Origin v1.9 Installation
-------------------------------------------

# loosen up firewalld
firewall-cmd --set-default-zone=dmz
firewall-cmd --zone=dmz --add-rich-rule='rule family="ipv4" source address="0.0.0.0/0" accept'
systemctl restart firewalld    OR    firewall-cmd --reload
firewall-cmd --runtime-to-permanent
firewall-cmd --zone=dmz --list-all

# (DNS breaks when assigning hostname, set below in resolv.conf)
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Install docker
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

# Configure insecure docker registry
sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd --insecure-registry 172.30.0.0/16 --exec-opt native.cgroupdriver=systemd|" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker
docker version

# Download the latest OpenShift Origin binaries from https://github.com/openshift/origin/releases currently 3.9.0. Extract files and copy file to folder included in PATH environment variable such as /usr/bin directory.
export OPENSHIFT_VERSION=3.9.0-191fece
export OPENSHIFT_VERSION_BASE=3.9.0
yum install -y wget 
wget https://github.com/openshift/origin/releases/download/v${OPENSHIFT_VERSION_BASE}/openshift-origin-server-v${OPENSHIFT_VERSION}-linux-64bit.tar.gz
tar -xzf openshift-origin-server-v${OPENSHIFT_VERSION}-linux-64bit.tar.gz
rm -f openshift-origin-server-v${OPENSHIFT_VERSION}-linux-64bit/LICENSE  openshift-origin-server-v${OPENSHIFT_VERSION}-linux-64bit/README.md
cp openshift-origin-server-v${OPENSHIFT_VERSION}-linux-64bit/* /usr/bin/

export EXTERNAL_IP=$(curl -s https://ipinfo.io/ip/)
mkdir -p /var/lib/origin/
cd /var/lib/origin/
openshift start master \
  --master="https://${EXTERNAL_IP}:8443" \
  --dns="https://0.0.0.0:8053" \
  --write-config="/var/lib/origin/openshift.local.config/master"

sed -i "s/router.default.svc.cluster.local/${EXTERNAL_IP}.nip.io/" \
  openshift.local.config/master/master-config.yaml

export OPENSHIFT_HOSTNAMES=kubernetes.default.svc.cluster.local,localhost,openshift.default.svc.cluster.local,127.0.0.1,172.17.0.1,172.18.0.1,172.19.0.1,172.30.0.1,192.168.122.1,192.168.42.1,$HOSTNAME,$EXTERNAL_IP

oc adm create-node-config \
  --dns-ip='172.30.0.1' \
  --node-dir=/var/lib/origin/openshift.local.config/node-localhost \
  --node=localhost --hostnames=$OPENSHIFT_HOSTNAMES

# Make sure 8443 enabled for the console to be browser accessible
firewall-cmd --permanent --add-port 8443/tcp
systemctl restart firewalld

# Install httpd-tools
yum install -y httpd-tools
htpasswd -c /var/lib/origin/openshift.local.config/master/users.htpasswd developer
(buildmaster1)

# Huge replace string just to enable password:
perl -0777 -i.original -pe 's|- challenge: true\n    login: true\n    mappingMethod: claim\n    name: anypassword\n    provider:\n      apiVersion: v1\n      kind: AllowAllPasswordIdentityProvider|- name: my_htpasswd_provider\n    challenge: true\n    login: true\n    mappingMethod: add\n    provider:\n      apiVersion: v1\n      kind: HTPasswdPasswordIdentityProvider\n      file: /var/lib/origin/openshift.local.config/master/users.htpasswd|igs' /var/lib/origin/openshift.local.config/master/master-config.yaml

# The above results in the below update in /var/lib/origin/openshift.local.config/master/master-config.yaml
identityProviders:
  - name: my_htpasswd_provider
    challenge: true
    login: true
    mappingMethod: add
    provider:
      apiVersion: v1
      kind: HTPasswdPasswordIdentityProvider
      file: /var/lib/origin/openshift.local.config/master/users.htpasswd


export EXTERNAL_IP=$(curl -s https://ipinfo.io/ip/)
oc cluster down
oc cluster up --use-existing-config --public-hostname="${EXTERNAL_IP}"


# Openshift Web Console: https://172.105.105.164:8443/console



Persistent Volume creation
--------------------------

Edit master-config.yaml under /var/lib/origin/openshift.local.config/master to enable the use of local volumes:

apiServerArguments:
   feature-gates:
   - PersistentLocalVolumes=true
...

 controllerArguments:
   feature-gates:
   - PersistentLocalVolumes=true
...