@test "Invoking dgoss without GOSS_PATH prints an error" {
    run ../dgoss
    [ "$status" -eq 1 ]
    [ "$output" = "ERROR: Couldn't find goss installation, please set GOSS_PATH to it" ]
}