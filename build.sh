set -xe

OVIRTVERS=3.5
DSTDIR=$2

sudo yum install -y docker
sudo service docker start

# Clone framework
git clone https://github.com/jasonbrooks/byo-atomic.git
pushd byo-atomic

# Build the build-env
sudo docker build --rm -t $USER/atomicrepo .
sudo docker rm -f -v atomicrepo || :
sudo docker run --privileged -v $PWD:/builddir -d --name atomicrepo $USER/atomicrepo
incontainer() { sudo docker exec atomicrepo $@ ; }


for OVIRTVER in $OVIRTVERS;
do
  echo Building repo for "$OVIRTVER"

  # Clone the defs
  if [[ ! -e node ]]; then
    git clone https://github.com/fabiand/sig-atomic-buildscripts.git node
    git checkout ovirt-host
  fi
  pushd node
    git clean -fdx
    git reset --hard ovirt-host
    make OVIRTVER=$OVIRTVER
  popd

  # Build the tree
  incontainer cp -v /builddir/node/RPM-GPG-ovirt /etc/pki/rpm-gpg/RPM-GPG-ovirt-$OVIRTVER
  incontainer rpm-ostree compose tree --repo=/srv/rpm-ostree/repo/ /builddir/node/centos-ovirt-host.json
  incontainer du -hs /srv/rpm-ostree
  sudo docker cp atomicrepo:/srv/rpm-ostree .

  if [[ -n "$DSTDIR" ]]; then
    rsync -PHvarc rpm-ostree/repo "$DSTDIR"
    rm -rf rpm-ostree
  fi
done
