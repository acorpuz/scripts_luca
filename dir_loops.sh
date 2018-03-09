#!/bin/bash
#
###############################################################################
# Lo script presume che la struttura delle directory sia la seguente:
#
# ├── configs
# │   └── file.generati.dallo.script.cfg
# ├── data
# │   └── file.csv
# ├── dir_loops.sh (questo script)
# └── template.cfg (template di configurazione da cui generare i file .cfg)
#
###############################################################################
#
# Per come e' scritto lo script, considerando che i *.csv sono
# in una sottodirectory chiamata data e cicla tutti i file .csv presenti

# check for root
if [ "$EUID" -ne 0 ]; then
	echo "Run script as root or use sudo."
	exit 1
fi

csv_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/data
echo "Script running in " $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "Using csv directory: " $csv_dir

for i in $csv_dir/*.csv; do
	# estraggo il nome base del file e lo uso per personalizzare 
	# il file di configurazione cfg ed i log
	csvfile=$i
	filename=$(basename "$i" .csv)
	conf_file=configs/$filename.cfg
	
	echo "Using csv file: "$i
	echo -e "\tBase name: "$filename
	echo -e "\tcfg file:" $conf_file
	echo "==================================================="
	echo "Creating cfg file from template ..."
	
	# cleanup old cfg files
	if [ -f $conf_file ];
	then
		echo -e "\tremoving old cfg file ..."
		rm $conf_file
	fi
	cp ./template.cfg $conf_file
	sed -i "s/XXX/$filename/g" $conf_file
	
	echo "Running program...."
	echo -e "\tUsing cfg file" $conf_file
	echo -e "\tLogging all data in ./logs/"
	
	# chiamata al programma
	./3incomms SIM -np $csvfile --config_file $conf_file
	echo "Done simulation for $filename"
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
done
