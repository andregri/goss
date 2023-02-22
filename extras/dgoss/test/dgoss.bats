# define stub for goss
function goss() {
    echo "goss"
}

function docker() {
    local CALL_DIR="$(pwd)"
    local CONTAINER_ID="1234"

    echo -e "docker $*" >>"${CALL_DIR}/docker.calls"

    if [[ "$*" == *--version* ]]; then
        echo "Docker version 20.10.5, build 55c4c88"
    fi
    if [[ $1 == "build" && "$*" == *docker-image-fail* ]]; then
        exit 1
    fi
    if [[ $1 == "run" && "${@:5}" == "image cmd" ]]; then
        echo "$CONTAINER_ID" # container id
    fi
    if [[ "$*" == "inspect -f {{.State.Running}} ${CONTAINER_ID}" ]]; then
        echo true
    fi
    if [[ $1 == "cp" ]]; then
        touch "$3"
    fi
}

teardown() {
    for file in "goss" "goss.yaml" "goss_wait.yaml"; do
        echo $file
        if [[ -f $file ]]; then
            rm $file
        fi
    done
}

@test "Invoking dgoss without GOSS_PATH prints an error" {
    bats_require_minimum_version 1.5.0
    unset GOSS_PATH

    run -1 ../dgoss
    [ "$output" = "ERROR: Couldn't find goss installation, please set GOSS_PATH to it" ]
}

@test "Invoking dgoss without arguments prints the usage" {
    bats_require_minimum_version 1.5.0
    export GOSS_PATH="goss"

    # make goss stub available to subshells
    export -f goss

    # invoke dgoss without args
    run -1 ../dgoss

    # assert
    [ "$output" = "ERROR: USAGE: dgoss [run|edit] <docker_run_params>" ]
}

@test "Invoking dgoss with a container runtime different from docker or podman prints an error" {
    bats_require_minimum_version 1.5.0
    export GOSS_PATH="goss"
    export CONTAINER_RUNTIME="test"
    export -f goss

    run -1 ../dgoss test

    [ "$output" = "ERROR: Runtime must be one of docker or podman" ]
}

@test "Invoking dgoss run <image> <cmd> starts the container, run tests, and delete the container" {
    bats_require_minimum_version 1.5.0

    export GOSS_PATH="goss"
    export -f goss
    touch goss # to pass cp command

    export CONTAINER_RUNTIME="docker"
    export -f docker

    run -0 ../dgoss run image cmd

    [ "${lines[0]}" = "INFO: Starting docker container" ]
    [ "${lines[1]}" = "INFO: Container ID: 1234" ]
    [ "${lines[2]}" = "INFO: Sleeping for 0.2" ]
    [ "${lines[3]}" = "INFO: Container health" ]
    [ "${lines[4]}" = "INFO: Running Tests" ]
    [ "${lines[5]}" = "INFO: Deleting container" ]
}

@test "Invoking dgoss without a valid command prints the usage" {
    bats_require_minimum_version 1.5.0

    export GOSS_PATH="goss"
    export -f goss
    touch goss # to pass cp command

    export CONTAINER_RUNTIME="docker"
    export -f docker

    run -1 ../dgoss test

    [ "$output" = "ERROR: USAGE: dgoss [run|edit] <docker_run_params>" ]
}

@test "Invoking dgoss edit <img> <cmd> starts the container and copy the file from it" {
    bats_require_minimum_version 1.5.0

    export GOSS_PATH="goss"
    export -f goss
    touch goss # to pass cp command

    export CONTAINER_RUNTIME="docker"
    export -f docker

    run -0 ../dgoss edit image cmd

    [ "${lines[0]}" = "INFO: Starting docker container" ]
    [ "${lines[1]}" = "INFO: Container ID: 1234" ]
    [ "${lines[2]}" = "INFO: Run goss add/autoadd to add resources" ]
    [ "${lines[3]}" = "INFO: Copied '/goss/goss.yaml' from container to './goss.yaml'" ]
    [ "${lines[4]}" = "INFO: Copied '/goss/goss_wait.yaml' from container to './goss_wait.yaml'" ]
    [ "${lines[5]}" = "INFO: Deleting container" ]
}