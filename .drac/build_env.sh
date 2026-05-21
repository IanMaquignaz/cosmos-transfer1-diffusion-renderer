#!/bin/bash

##------------------------##
#### PYTHON Environment ####
##------------------------##
### See: https://docs.alliancecan.ca/wiki/Python#Python_version_supported

# Clear modules
# deactivate
module --force purge

# Export module list
. .drac/export_env_modules.sh -b

# Prevent error when SLURM_TMPDIR is not defined.
if [ ! -d "$SLURM_TMPDIR" ]; then
    SLURM_TMPDIR=$(pwd)
fi

# Purge existing environment
if [ -z "$1" ];
then
    # String is empty; use default
    ENV_BUILD_DIR="$SLURM_TMPDIR/$ENV_NAME"
else
    ENV_BUILD_DIR="$1"
fi
echo "Environment build directory: $ENV_BUILD_DIR"

if [ -d  $ENV_BUILD_DIR ]; then
    read -t 10 -p "Do you want clear the environment $ENV_BUILD_DIR? (yes/no) " answer
    answer=${answer:-n}
    case $answer in
        [Yy]* ) virtualenv --clear $ENV_BUILD_DIR \
            && echo -e "\nDeleted $ENV_BUILD_DIR" \
            && rm -r .drac/wheel_cache/*.whl \
            && echo "Deleted .drac/wheel_cache/*.whl" ;;
        [Nn]* ) echo -e "\n Skipping deletion of $ENV_BUILD_DIR";;
        * ) echo "Please answer yes or no.";;
    esac
fi


# Create the environment
virtualenv --no-download $ENV_BUILD_DIR

# Activate the environment
source $ENV_BUILD_DIR/bin/activate
ENV_SOURCE="$ENV_BUILD_DIR/bin/activate"

# Prevent python installs outside of an environment
export PIP_REQUIRE_VIRTUALENV=1

# Upgrade pip
$PYTHON -m pip install --no-index --upgrade pip

### WARNING!
# DO NOT INCLUDE WHEELS PROVIDED BY COMPUTE CANADA MODULES IN THE REQUIREMENTS FILEs
# E.g. opencv-python is provided by the opencv module, but including opencv-python in the requirements file will cause a crash.

# 1. Fastest & Most Reliable Source
# Install dependencies (internal; --no-index searches computecanada)
# For available python wheels, see https://docs.alliancecan.ca/wiki/Available_Python_wheels
# DANGER! Names don't necessarily match those of wheels on PYPI!
$PYTHON -m pip install --no-index --no-cache-dir -r .drac/requirements_python_internal.txt
if [ $? -ne 0 ]; then
    echo "Error installing internal dependencies."
    exit 1
fi

# 2. For missing, but dependencies already installed
# Install dependencies (external; use pypi and skip dependencies)
$PYTHON -m pip install --no-cache-dir --no-deps -r .drac/requirements_python_external_w_internalDeps.txt
if [ $? -ne 0 ]; then
    echo "Error installing external dependencies with internal deps."
    exit 1
fi

# 3. Worst case
# Install dependencies (external; use pypi)
# # DANGER! THIS REQUIRES AN INTERNET CONNECTION!!
$PYTHON -m pip install -r .drac/requirements_python_external.txt
if [ $? -ne 0 ]; then
    echo "Error installing internal dependencies."
    exit 1
fi

# # SAFER: Download the wheels if possible, else install from cache
# # Check for external internet connection
# wget -q --spider https://www.google.com
# if [ $? -eq 0 ]; then
#     # Download Wheels
#     echo "Downloading offline python wheels"
#     $PYTHON -m pip wheel --wheel-dir=.drac/wheel_cache --progress-bar on -r .drac/requirements_python_external.txt
# fi
# # Install
# $PYTHON -m pip install --no-index --find-links=.drac/wheel_cache -r .drac/requirements_python_external.txt

$PYTHON -m pip install git+https://github.com/NVlabs/nvdiffrast.git --no-build-isolation

# Check if on login-node
if [ -z "$SLURM_JOB_NAME" ];
then
    # To force a rebuild of the wheels
    echo -e "\nON LOGIN NODE\n"
    echo -e "Deleting .drac/wheel_cache/*.whl to force a rebuild\n"
    # Delete the wheel cache
    rm -rf .drac/wheel_cache/*.whl
else
    # To force a rebuild of the wheels
    echo -e "\nON SLURM NODE=$SLURM_JOB_NAME\n\t"
fi

# Export module list (complete)
. .drac/export_env_modules.sh

# Deactivate the environment
deactivate
