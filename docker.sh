#!/bin/bash
CONTAINER_TAG="COSMOS" # Suggest
CONTAINER_PROJECT_NAME="ian" # Suggest

CONTAINER_NAMETAG="$CONTAINER_PROJECT_NAME-$CONTAINER_TAG" # Suggest

echo "<?> CONTAINER NAME: $CONTAINER_NAMETAG <?>"

ARG_USER="-u $(whoami)"
COMMAND='/bin/bash'
POSITIONAL_ARGS=()
DOCKER_BUILD=false
DOCKER_START=false
CC_CLUSTER=$(hostname -f)

# Get command line arguments
OPTIONS=bsfru:e:htTp:   # -b build, -r run, -e execute, -h help
OPTIND=1 # Holds the number of options parsed by the last call to getopts. Reset in case getopts has been used previously in the shell
while getopts $OPTIONS opt; do
    case "${opt}" in
        b) # Build
            DOCKER_BUILD=true
            ;;
        s) # Start
            DOCKER_START=true
            ;;
        r) # Run as Root
            ARG_USER=' -u root '
            ;;
        u) # Run as user
            ARG_USER=" -u $OPTARG "
            ;;
        c) # Execute command
            COMMAND=$OPTARG
            ;;
        f) # No docker cache
            NO_CACHE=' --no-cache '
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


if [[ $DOCKER_BUILD == true ]]; then
    echo "<?> STARTING DOCKER BUILD <?>"
    docker compose --project-name $CONTAINER_PROJECT_NAME --file .docker/compose.yml stop $CONTAINER_TAG
    docker compose --project-name $CONTAINER_PROJECT_NAME --file .docker/compose.yml rm -f
    docker compose --file .docker/compose.yml pull
    docker compose --project-name $CONTAINER_PROJECT_NAME -f .docker/compose.yml build $NO_CACHE --build-arg USER_NAME=$(whoami) --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)

    if [[ $? -ne 0 ]]; then
        echo "<?> DOCKER BUILD FAILED <?>"
        exit 1
    fi

    docker compose --project-name $CONTAINER_PROJECT_NAME --file .docker/compose.yml up --detach --no-recreate -d $CONTAINER_TAG

elif [[ $DOCKER_START == true ]]; then
    echo "<?> STARTING DOCKER CONTAINER <?>"
    docker compose --project-name $CONTAINER_PROJECT_NAME --file .docker/compose.yml up --detach --no-recreate -d $CONTAINER_TAG

fi

echo "<?> STARTING SHELL IN CONTAINER <?>"
docker compose --project-name $CONTAINER_PROJECT_NAME exec  $CONTAINER_TAG $COMMAND
