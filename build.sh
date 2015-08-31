bash -xe

sudo yum install -y docker
sudo service docker start

# Clone the defs
git clone https://github.com/fabiand/sig-atomic-buildscripts.git node
pushd node
  git checkout ovirt-host
  make
popd

# Build the build-env
sudo docker build --rm -t $USER/atomicrepo .
sudo docker rm -f -v atomicrepo || :
sudo docker run --privileged -v $PWD:/builddir -d --name atomicrepo $USER/atomicrepo
incontainer() { sudo docker exec atomicrepo $@ ; }

# Build the tree
incontainer cp -v /builddir/node/RPM-GPG-ovirt /etc/pki/rpm-gpg/RPM-GPG-ovirt-3.6
incontainer rpm-ostree compose tree --repo=/srv/rpm-ostree/repo/ /builddir/node/centos-ovirt-host.json
incontainer du -hs /srv/rpm-ostree
sudo docker cp atomicrepo:/srv/rpm-ostree .
