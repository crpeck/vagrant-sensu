#!/bin/bash
#
# this runs after puppet provision is finished
#
PROGNAME=post-puppet.sh
RANFILE=/tmp/post-puppet.ran
#
if [ -f ${RANFILE} ]; then
  echo "${PROGNAME} shell provisioner already ran, skipping it this time"
  echo "if you want it to run:"
  echo "vagrant ssh -c \"rm ${RANFILE}\""
  echo "vagrant provision"
  exit 0
fi

echo -e "\nStarting Post Install provisioning ${PROGNAME}"
#
# place commands to run after puppet here
#
echo -e "\nCreating file ${RANFILE}, to run ${PROGNAME} during provisioning again you"
echo "must remove the file named ${RANFILE} inside the vagrant box"
date > ${RANFILE}
#
echo -e "\n${PROGNAME} finished\n"
exit 0

