# define stub for goss
function goss() {
    echo "goss"
}

@test "Invoking dgoss without GOSS_PATH prints an error" {
    unset GOSS_PATH

    run -1 ../dgoss
    [ "$output" = "ERROR: Couldn't find goss installation, please set GOSS_PATH to it" ]
}

@test "Invoking dgoss without arguments prints the usage" {
    export GOSS_PATH="goss"

    # make goss stub available to subshells
    export -f goss

    # invoke dgoss without args
    run -1 ../dgoss

    # assert
    [ "$output" = "ERROR: USAGE: dgoss [run|edit] <docker_run_params>" ]
}

@test "Invoking dgoss with a container runtime different from docker or podman prints an error" {
    export  GOSS_PATH="goss"
    export  CONTAINER_RUNTIME="test"
    export -f goss
    
    run -1 ../dgoss test

    [ "$output" = "ERROR: Runtime must be one of docker or podman" ]
}