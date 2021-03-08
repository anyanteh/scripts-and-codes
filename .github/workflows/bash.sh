





#!/bi/bash
# Capablities:
# - VM Stats
# - Create n VM
# - Destroy all VM
# - Start all VM
# - Stop all VM
# ToDo:
# - Start/Stop vm on particular host.

# New VMs var
# Zone ID of the new VM.
# cmd: cloudmonkey list zones filter=name,id
zoneid=""
# Template ID for the new VM.
# cmd: cloudmonkey list templates templatefilter=all filter=name,id
templateid=""
# Serviceoffering ID for the new VM.
# cmd: cloudmonkey list serviceofferings filter=name,id
serviceofferingid=""
# Networks IDs for the new VM.
# cmd: cloudmonkey list networks filter=name,id
networkids=""

# Input var
action="$1"
vms="$2"

#echo $action
#echo $vms

# Script Start
if [ "$action" == "stats" ]; then

	#Stats
	running="$(cloudmonkey list virtualmachines filter=id,state | grep Running | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12} | wc -l)"
	stopped="$(cloudmonkey list virtualmachines filter=id,state | grep Stopped | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12} | wc -l)"
	starting="$(cloudmonkey list virtualmachines filter=id,state | grep Starting | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12} | wc -l)"
	stopping="$(cloudmonkey list virtualmachines filter=id,state | grep Stopping | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12} | wc -l)"
	vmerror="$(cloudmonkey list virtualmachines filter=id,state | grep Error | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12} | wc -l)"
	echo Number of Running VMs: "${running}"
	echo Number of Stopped VMs: "${stopped}"
	echo Number of Starting VMs: "${starting}"
	echo Number of Stopping VMs: "${stopping}"
	echo Number of VMs in Error State: "${vmerror}"

elif [ "$action" == "startall" ]; then

	#Start All Stopped VMs
	while read -r line ; do
		echo "Starting VM id: $line"
		cloudmonkey start virtualmachine id=$line > /dev/null 2>&1 &
	done < <(cloudmonkey list virtualmachines filter=id,state | grep Stopped | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12})

elif [ "$action" == "stopall" ]; then

	#Stop All Running VMs
	while read -r line ; do
		echo "Stopping VM id: $line"
		cloudmonkey stop virtualmachine id=$line > /dev/null 2>&1 &
	done < <(cloudmonkey list virtualmachines filter=id,state | grep Running | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12})

elif [ "$action" == "destroyall" ]; then

	read -p "WARNING!!! This will destroy all the VMs of your account!!! Are you sure? (y/N)" -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then

		#Destroy All VMs
		while read -r line ; do
			echo "Destroing VM id: $line"
			cloudmonkey destroy virtualmachine id=$line expunge=true > /dev/null 2>&1 &
		done < <(cloudmonkey list virtualmachines filter=id,state | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12})

	fi

elif [ "$action" == "destroyerror" ]; then

        read -p "WARNING!!! This will destroy all the VMs in error state!!! Are you sure? (y/N)" -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then

                #Destroy All VMs in error state
                while read -r line ; do
                        echo "Destroing VM id: $line"
                        cloudmonkey destroy virtualmachine id=$line expunge=true > /dev/null 2>&1 &
                done < <(cloudmonkey list virtualmachines filter=id,state | grep Error | grep -Phro [a-f,0-9]{8}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{4}-[a-f,0-9]{12})

        fi

elif [ "$action" == "create" ]; then

	read -p "WARNING!!! This will create $vms VMs, Are you sure? (y/N)" -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then

		#Create VMs + Stats
		printf "\nCreating $vms VMs ...\n"
        	for (( c=1; c<=$vms; c++)) ;
			do cloudmonkey deploy virtualmachine zoneid=$zoneid templateid=$templateid serviceofferingid=$serviceofferingid networkids=$networkids > /dev/null 2>&1 &
			done
		fi

elif [ "$action" == "list" ]; then

	echo "Zones List:"
	cloudmonkey list zones filter=name,id
	echo "Templates List:"
	cloudmonkey list templates templatefilter=all filter=name,id
	echo "Service Offerings List:"
	cloudmonkey list serviceofferings filter=name,id
	echo "Networks List:"
	cloudmonkey list networks filter=name,id

elif [ "$action" == "cluster" ]; then

        echo "Clusters List:"
	cloudmonkey list clusters filter=allocationstate,clustertype,hypervisortype,managedstate,name,podname,zonename
        echo "Hosts List:"
	cloudmonkey list hosts filter=name,clustername,clustertype,resourcestate,state

elif [ "$action" == "capacity" ]; then

        echo "Capacity: (capacity.skipcounting.hours and restart mgmt server)"
        cloudmonkey list capacity

else

	echo "Cloudzor Help:"
	echo "stats - Display VMs stats"
	echo "startall - Start all VMs of the current account"
	echo "stopall - Stop all VMs of the current account"
	echo "destroyall - Destroy all VMs of the current account"
	echo "destroyerror - Destroy all VMs in error state"
	echo "create n - Create n VMs on the current account"
	echo "list - List Zone, Templates, Service Offerings, and Networks"
        echo "cluster - List Clusters and Hosts"
	echo "capacity - Show CloudStack Capacity"

fi

#End

exit 0









