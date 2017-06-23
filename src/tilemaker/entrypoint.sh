#!/bin/bash

# Downloads a shapefile and converts it to raster tiles that it writes to S3

set -e
source /opt/pfb/tilemaker/scripts/utils.sh

export TL_MIN_ZOOM="${TL_MIN_ZOOM:-8}"
export TL_MAX_ZOOM="${TL_MAX_ZOOM:-17}"
export TL_NUM_PARTS="${TL_NUM_PARTS:-4}"
export TIME="\nTIMING: %C\nTIMING:\t%E elapsed %Kkb mem\n"

if [ -z "${PFB_JOB_ID}" ]; then
    echo "Error: PFB_JOB_ID is required"
    exit 1
fi

echo "Exporting tiles"

set +e
/opt/pfb/tilemaker/scripts/run_tilemaker.sh
PFB_EXIT_STATUS=$?
set -e

if [ $PFB_EXIT_STATUS -eq  0 ]; then
    echo "Finished exporting tiles"
else
    echo "Failed" "See job logs for more details."
fi

# Drop to a shell if run interactively
bash

exit $PFB_EXIT_STATUS
