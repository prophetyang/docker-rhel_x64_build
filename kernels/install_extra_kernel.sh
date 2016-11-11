#!/bin/bash -x 

EXTRA_KERNELS="2.6.32-71.el6.x86_64 2.6.32-220.el6.x86_64 2.6.32-358.2.1.el6.x86_64 2.6.32-431.el6.x86_64 2.6.32-431.17.1.el6.x86_64 2.6.32-504.12.2.el6.x86_64 2.6.32-431.20.5.el6.x86_64 2.6.32-431.23.3.el6.x86_64"

for i in $EXTRA_KERNELS; do 
	echo "Prepare to install extra kernel $i";
	rpm -hvi --force /tmp/*$i.rpm; 
	mkdir -p /lib/modules/$i;
	ln -s /usr/src/kernels/$i /lib/modules/$i/build;
	echo "Install extra kernel $i done"
done

rm -rf /tmp/*.rpm /tmp/install_extra_kernel.sh
