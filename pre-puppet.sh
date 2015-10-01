#!/bin/bash
#
# vagrant pre-puppet provisoning script.
# Runs before puppet (See the Vagrantfile):
#  runs apt-get update (otherwise pkgs can't get installed)
#  installs ruby-dev (pre-req for librarian-puppet)
#  installs librarian-puppet via gem
#  runs librarian-puppet to install puppet modules
#  creates /tmp/pre-puppet.ran file, so another provision won't bother running this script
#
PROGNAME=pre-puppet.sh
RANFILE=/tmp/pre-puppet.ran
echo ""
#
if [ -f ${RANFILE} ]; then
  echo "${PROGNAME} shell provisioner already ran, skipping it this time"
  echo "if you want it to run:"
  echo "vagrant ssh -c \"rm ${RANFILE}\""
  echo "vagrant provision"
  exit 0
fi
#
echo "Provisioning..."
sudo apt-get update
#
echo -e "\nInstalling ruby-dev and git"
sudo apt-get install -y ruby-dev git
#
echo -e "\nInstalling librarian-puppet"
sudo gem install librarian-puppet --no-rdoc --no-ri
#
cd /vagrant/puppet
echo -e "\nInstalling puppet modules from Puppetfile"
librarian-puppet install
#
echo -e "\nInstalling eyaml via gem install"
gem install hiera-eyaml --no-rdoc --no-ri
#
#
echo -e "\nCreating file ${RANFILE}, to run ${PROGNAME} during provisioning again you"
echo "must remove the file named ${RANFILE} inside the vagrant box"
date > ${RANFILE}
#
echo -e "\n${PROGNAME} finished\n"
exit 0
