# defin stub for goss
function goss() {
    echo "goss stub"
}

@test "Invoking dgoss without GOSS_PATH prints an error" {
    # unset GOSS_PATH
    local GOSS_PATH=""

    run -1 ../dgoss
    [ "$output" = "ERROR: Couldn't find goss installation, please set GOSS_PATH to it" ]
}

@test "Invoking dgoss without arguments prints the usage" {
    local GOSS_PATH="goss"

    # make goss stub available to subshells
    export -f goss

    # invoke dgoss without args
    run -1 ../dgoss

    # assert
    [ "$output" = "ERROR: Couldn't find goss installation, please set GOSS_PATH to it" ]
}