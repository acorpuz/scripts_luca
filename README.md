# Note sullo script `dir_loops.sh`

Lo script presume che la struttura delle directory sia la seguente:

```
├── configs/
│   └── <file.generati.dallo.script>.cfg
├── data/
│   └── <file_dati>.csv
├── logs/           (creata dallo script)
│   ├── run_<date>.log
│   └── <job_name>.log
├── dir_loops.sh    (questo script)
└── template.cfg    (template di configurazione da cui generare i file .cfg)
```

Lo script considera che i \*.csv sono in una sottodirectory chiamata `data`,
e crea i file di configurazione .cfg in una sottodirectory chiamata `configs`. 

I file di configurazione generati avranno lo stesso nome del file di dati ma estensione
.cfg; lo script cicla tra tutti i file .csv presenti nella directory `data`. 

Lo script deve girare con privilegi di root per poter chiamare il programma del simulatore,
se eseguito con privilegi inferiori avvisa ed esce con errore 1.

Lo script cerca di essere esplicito nel comunicare su schermo cosa fa e su che file sta lavorando,
in ogni caso tutto l'output viene anche girato in un file di logi (`run_<data-ora>.log`) nella directory logs;
la directory logs conterrà anche i log dei songoli job.

### File template.cfg

Lo script usa la stringa `xxx` come identificativo di cosa cambiare nel file per generare
il file di configurazione opportuno.
