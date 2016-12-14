#!/bin/bash -xe
echo "build-artifacts.sh"

df -h || :
#this scripts build ovirt-node and ovirt-node-is projects
mknod /dev/kvm c 10 232
export PATH=$PATH:/usr/libexec
export ARTIFACTSDIR=$PWD/exported-artifacts
#export http_proxy=proxy.phx.ovirt.org:3128

git submodule update --init --recursive --force --remote

# Enter the Engine Appliance
pushd engine-appliance

 # Build imgfac to build Version.py
 pushd imagefactory
  python setup.py sdist
 popd

 mkdir tmp
 export TMPDIR="$PWD/tmp/"
 export PYTHON="PYTHONPATH='$PWD/imagefactory/' python"
 export OVANAME="oVirt-Engine-Appliance-CentOS-x86_64-7-$(date +%Y%m%d)"
 export QEMU_APPEND="ip=dhcp proxy="

 export PATH=$PATH:/sbin:/usr/sbin
 export TMPDIR=/var/tmp/

 mkdir "$ARTIFACTSDIR"

 # Create the OVA
 make

 # Do some sanity checks
 make check

 [[ -f ovirt-engine-appliance.ova ]] && ln -v ovirt-engine-appliance.ova "$ARTIFACTSDIR"/"${OVANAME}.ova"
 [[ -f ovirt-engine-appliance.qcow2 ]] && ln -v ovirt-engine-appliance.qcow2 "$ARTIFACTSDIR"/
 [[ -f ovirt-engine-appliance-manifest-rpm ]] && ln -v ovirt-engine-appliance-manifest-rpm "$ARTIFACTSDIR"/

 mv -v \
   anaconda.log \
   "$ARTIFACTSDIR/"

 # Finally, create the rpm
 make ovirt-engine-appliance.rpm

 mv -v \
   "$HOME"/rpmbuild/RPMS/*/*.rpm \
   "$HOME"/rpmbuild/SRPMS/*.rpm \
   "$ARTIFACTSDIR/"
 ls -shal "$ARTIFACTSDIR/" || :
