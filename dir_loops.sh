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

work_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
csv_dir="${work_dir}/data"
run_log_name="logs/run_$(date +"%Y_%m_%d-%T").log"

echo "Script running in ${work_dir}" | tee -a "$run_log_name"
echo "Using csv directory: ${csv_dir}" | tee -a "$run_log_name"
echo "Checking log dir..." | tee -a "$run_log_name"
if [ ! -e ./logs ]; then
    mkdir ./logs
    chown 775 ./logs
fi

for i in $csv_dir/*.csv; do
	# estraggo il nome base del file e lo uso per personalizzare 
	# il file di configurazione cfg ed i log
	csvfile=$i
	filename=$(basename "$i" .csv)
	conf_file=configs/$filename.cfg
	
	echo "Using csv file: ${i}" | tee -a "$run_log_name"
	echo -e "\tBase name: ${filename}" | tee -a "$run_log_name"
	echo -e "\tcfg file: ${conf_file}" | tee -a "$run_log_name"
	echo "===================================================" | tee -a "$run_log_name"
	echo "Creating cfg file from template ..." | tee -a "$run_log_name"
	
	# cleanup old cfg files
	if [ -f "$conf_file" ];
	then
		echo -e "\tremoving old cfg file ..." | tee -a "$run_log_name"
		rm "$conf_file"
	fi
	cp ./template.cfg "$conf_file"
	sed -i "s/XXX/${filename}/g" "$conf_file"
	
	echo "Cleaning up data file ${csvfile} ..." | tee -a "$run_log_name"
    # get max value in file
    maxval=$(tail -n1 "${csvfile}" | cut -d , -f 1 )
    # count occurances, ideally only 2
    last_lines=$(grep -c "$maxval" "${csvfile}")
    if [ "$last_lines" -gt 2 ]; then
        echo "Extra lines foud in ${csvfile}, deleting lines ..." | tee -a "$run_log_name"
        # delete lines matching the pattern 
        grep -v "$maxval,.,up" "${csvfile}" > "${csvfile}.tmp"
        mv "${csvfile}.tmp" "${csvfile}"
    fi

	echo "Running program...." | tee -a "$run_log_name"
	echo -e "\tUsing cfg file" "$conf_file" | tee -a "$run_log_name"
	echo -e "\tLogging all data in logs/" | tee -a "$run_log_name"
	
	# chiamata al programma, levare il commento
#	./3incomms SIM -np "$csvfile" --config_file "$conf_file"
	echo "Done simulation for ${csvfile}" | tee -a "$run_log_name"
    echo "Waiting 5 seconds ..." | tee -a "$run_log_name"
    sleep 5
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++" | tee -a "$run_log_name"
done
