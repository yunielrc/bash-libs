#!/usr/bin/env bash

. "${LIBS_DIR}/bats-support/load.bash"
. "${LIBS_DIR}/bats-assert/load.bash"

export NOLOCK=true
export ENV=testing
readonly NOLOCK ENV

cd "$BATS_TEST_DIRNAME" || exit
