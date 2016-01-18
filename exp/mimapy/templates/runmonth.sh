#!/usr/bin/env bash
# Run a single month



cd {{ rundir }}

# copy and extract the restart information
{% if restart_file %}
cd INPUT
cp {{ restart_file }} res
cpio -iv < res
cd {{ rundir }}
{% endif %}

export MALLOC_CHECK_=0

ln -s {{ execdir }}/fms_moist.x fms_moist.x
mpirun  -np {{ num_cores }} fms_moist.x

# combine output files
echo Month {{ month }} complete, combining nc files

if [ {{ num_cores }} > 1 ]; then
 for ncfile in `/bin/ls *.nc.0000`; do
    {{ execdir }}/mppnccombine.x $ncfile
    if [ $? == 0 ]; then
        rm -f "${ncfile%.*}".????
    fi
 done
fi

