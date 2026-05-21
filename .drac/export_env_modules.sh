#!/bin/bash

# Get command line arguments
ADD_EXTRA_MODULES=true
OPTIONS=b   # -b build, -h help
OPTIND=1 # Holds the number of options parsed by the last call to getopts. Reset in case getopts has been used previously in the shell
while getopts $OPTIONS opt; do
    case "${opt}" in
        b) # Build
            ADD_EXTRA_MODULES=false
            ;;
        \?) # Invalid option
            echo "Invalid option: -$opt" >&2
            exit 1
            ;;
        h) # Help
            echo "Need help? There is no help. Read the code."
            exit 0
            ;;
    esac
done
shift $((OPTIND-1)) # remove options that have already been handled from $@


# Load modules
# See https://docs.alliancecan.ca/wiki/Available_software
# or use 'module spider <your_package>'
PYTHON_VERSION="3.11.2"
PYTHON="python3.11" # Adding .2 causes error.

# Comet
# If on rorqual or Narval, required httpproxy
EXTRA_MODULES=""
if [[ $CC_CLUSTER == *"rorqual"* ]] || [[ $CC_CLUSTER == *"narval"* ]]; then
  MODULES="httpproxy"
  if [[ $ADD_EXTRA_MODULES == true ]]; then
    EXTRA_MODULES=$MODULES
  else
    echo "Build mode: Extra modules were skipped! ($MODULES)"
  fi
fi
# EXTRA_MODULES="httpproxy"

ENV_NAME="ENV_COSMOS"
# cudacore/.12.9.1 cudnn/9.13.1.26
export ${ENV_NAME}_MODULES="StdEnv/2023 gcc/12.3 cuda/12.2 cudacore/.12.2.2 cudnn/9.2.1.18 python/$PYTHON_VERSION arrow/24 opencv/4.13 $EXTRA_MODULES"
eval ENV_MODULES=\$${ENV_NAME}_MODULES
echo "Exported ${ENV_NAME}_MODULES=$ENV_MODULES"
module load $ENV_MODULES
