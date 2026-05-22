#!/bin/bash
LSDIR='/usr/local/lsws'

if [ -z "$(ls -A -- "${LSDIR}/conf/")" ]; then
	cp -R ${LSDIR}/.conf/* ${LSDIR}/conf/
fi
if [ -z "$(ls -A -- "${LSDIR}/admin/conf/")" ]; then
	cp -R ${LSDIR}/admin/.conf/* ${LSDIR}/admin/conf/
fi
if [ ! -e ${LSDIR}/conf/serial.no ] && [ ! -e ${LSDIR}/conf/license.key ]; then
    rm -f ${LSDIR}/conf/trial.key*
    wget -P ${LSDIR}/conf/ http://license.litespeedtech.com/reseller/trial.key
fi
chown -R lsadm:lsadm /usr/local/lsws/conf
chown -R lsadm:lsadm /usr/local/lsws/admin/conf
chmod -R u=rwX,go= /usr/local/lsws/admin/conf

/usr/local/lsws/bin/lswsctrl start
"$@"
while true; do
	if ! ${LSDIR}/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done