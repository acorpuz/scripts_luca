#!/bin/bash
#
# Script per impostare gli ip sugli adattatori di rete
# Necessita di privilegi root o sudo; assumo netmask 255.255.255.0 fissa
# Param: nome delle schede separate da virgola; ip da assegnare separati da virgola
################################################################################

. /lib/lsb/init-functions

show_usage(){
	echo ""
	echo "Uso: `basename $0`  eth0,ip0 eth1,ip1 ... ethn,ipn"
    exit 0
}

if [ "$#" -eq 0 ]; then
    show_usage
    exit 0
else
	# controlliamo se siamo root
	if [ "$EUID" -ne 0 ]; then
		echo "Run scripts as root or use sudo."
		exit 1
	fi

    # read inputs...
    log_action_begin_msg "Lettura dei parametri in input per la configurazione delle interfacce"
    for var in "$@"; do
        IFS=',' read -ra netarr <<< $var
        target_ip=${netarr[1]}
        target_dev=${netarr[0]}
        log_action_cont_msg "Impostazione dell'IP ${target_ip} al network device ${target_dev}"
        
        # elimino tutti gli IP del device
        id addr flush dev $target_dev 
        
        # Aggiungo quello desiderato
        ip addr add "${target_ip}/24" dev "$target_dev"
        ip link set dev "$target_dev" up
    done

    log_action_end_msg 0 "Interfacce configurate"
            
fi

exit 0
