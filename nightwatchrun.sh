#!/usr/bin/env bash

OPTIND=1

config_file=
environment='stable'
worker_count="auto"
execution_count=1
container_ver='latest'
local_ip=''
debug=0
selenium_container='selenium/standalone-chrome'


while getopts ":c:e:w:v:i:dx:" opt; do
    case "$opt" in
    c)  config_file=$OPTARG
        ;;
    e)  environment=$OPTARG
        ;;
    w)  worker_count=$OPTARG
        ;;
    v)  container_ver=$OPTARG
        ;;
    i)  local_ip=$OPTARG
        ;;
    d)  debug=1
        ;;
    x)  execution_count=$(($OPTARG + 0))
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ -z "$config_file" -o ! -f "$config_file"  ]; then
    echo "Configuration file is required, provide with -c CONFIG"
    exit 1
fi

if [ -f ./env/$environment ]; then
    source ./env/$environment
else
    echo "Environment does not exist. Can't continue."
    exit 1
fi

if [ $debug -eq 1 ]; then
    selenium_container="$selenium_container-debug"
    export NW_WORKER=false
    worker_count="1"
fi

if [ "$worker_count" == "1" ]; then
    export NW_WORKER=false
    export NW_WORKER_COUNT=$worker_count
else
    export NW_WORKER=true
    export NW_WORKER_COUNT=$worker_count
fi

if [ $execution_count -lt 1 ]; then
    execution_count=1
fi

echo "Starting selenium testing against environment: $environment with version $container_ver"
echo "Using config file: $config_file"

DOCKER_NAME="nightwatchrun.${config_file}"

# Always make sure the docker container is stopped
trap 'echo "Force removing docker container."; docker rm -fv "${DOCKER_NAME}"; exit 1' INT TERM EXIT

# Get the real location for our current working directory. Jenkins has a symlink somewhere in it's path...
CWD=$(pwd -P)

# Let's start up the docker container
docker run -d -P -v ${CWD}:${CWD} -v /dev/shm:/dev/shm --name "$DOCKER_NAME" $selenium_container:$container_ver

if [ $? -ne 0 ]; then
    echo "Something went wrong with Docker."
    exit 1
fi

if [ $debug -eq 1 ]; then
    echo "VNC server has been started at (password is: 'secret'): "
    docker port "$DOCKER_NAME" 5900

    echo ""
    echo "Waiting for user to press enter before continuing."
    read DONE
fi

if [ -f ./env/$environment.prehook ];
then
    source ./env/$environment.prehook
fi

echo "Today's test are run against: "
docker exec -i "${DOCKER_NAME}" /opt/google/chrome/chrome --version

# Alright, we need to get some port information
IFS=":" read SELENIUM_HOST SELENIUM_PORT < <(docker port "$DOCKER_NAME" 4444)

echo "Selenium is running at $SELENIUM_HOST port $SELENIUM_PORT"

LIVECHECKTRIES=5
while [ $LIVECHECKTRIES -gt 0 ]; do
    curl -s "http://${SELENIUM_HOST}:${SELENIUM_PORT}/wd/hub/status" > /dev/null

    if [ $? -gt 0 ]; then
        echo "Selenium is not yet alive. Sleeping 1 second."
        sleep 1
    else
        break
    fi
    let LIVECHECKTRIES=LIVECHECKTRIES-1
done

export SELENIUM_HOST
export SELENIUM_PORT

EXECUTION_COUNTER=0
RETVAL=0

if [ $execution_count -gt 1 ]; then
    echo "Performing $execution_count execution(s) or until failure"
fi

while [  $EXECUTION_COUNTER -lt $execution_count ] && [ $RETVAL -eq 0 ]; do
    let EXECUTION_COUNTER=EXECUTION_COUNTER+1

    if [ $execution_count -gt 1 ]; then
        echo -e "\n[ Test pass #$EXECUTION_COUNTER ]"
    fi

    yarn run nightwatch -- -c "${config_file}" $@
    RETVAL=$?
done

if [ $RETVAL -gt 0 ]; then
    echo "Executed tests $EXECUTION_COUNTER times before encountering a failure"
else
    echo "Executed tests $EXECUTION_COUNTER times successfully"
fi

echo "Removing the docker container: $DOCKER_NAME"

docker rm -fv "$DOCKER_NAME"

trap - INT TERM EXIT

exit $RETVAL
