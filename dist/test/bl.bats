load test_helper

@test 'recursive_slink: to home' {
  (
    . "${DIST_PATH}/bl.bash"

    local -r from_dir=./fixtures/dir1
    local -r to_dir="$(mktemp -d)"

    run bl::recursive_slink "$from_dir" "$to_dir"

    assert_success
    assert_line --index 0 --regexp "mkdir: created directory '.+/.ssh'"
    assert_line --index 1 --regexp "'.+/.ssh/config' -> '.+/dist/test/fixtures/dir1/.ssh/config'"
    assert_line --index 2 --regexp "'.+/.inputrc' -> '.+/dist/test/fixtures/dir1/.inputrc'"
    assert_line --index 3 --regexp "'.+/.gitconfig' -> '.+/dist/test/fixtures/dir1/.gitconfig'"
  )
}

@test 'recursive_slink: to root' {
  (
    . "${DIST_PATH}/bl.bash"

    local -r from_dir=./fixtures/dir1
    local -r to_dir="$(sudo mktemp -d)"

    run bl::recursive_slink "$from_dir" "$to_dir"

    assert_success
    assert_line --index 0 --regexp "mkdir: created directory '.+/.ssh'"
    assert_line --index 1 --regexp "'.+/.ssh/config' -> '.+/dist/test/fixtures/dir1/.ssh/config'"
    assert_line --index 2 --regexp "'.+/.inputrc' -> '.+/dist/test/fixtures/dir1/.inputrc'"
    assert_line --index 3 --regexp "'.+/.gitconfig' -> '.+/dist/test/fixtures/dir1/.gitconfig'"

    run bl::recursive_slink "$from_dir" "$to_dir"

    assert_success
    assert_line --index 0 --regexp "'.+/.ssh/config~' ~ '.+/.ssh/config' -> '.+/dist/test/fixtures/dir1/.ssh/config'"
    assert_line --index 1 --regexp "'.+/.inputrc~' ~ '.+/.inputrc' -> '.+/dist/test/fixtures/dir1/.inputrc'"
    assert_line --index 2 --regexp "'.+/.gitconfig~' ~ '.+/.gitconfig' -> '.+/dist/test/fixtures/dir1/.gitconfig'"
  )
}
