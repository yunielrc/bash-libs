load test_helper

@test 'bl::recursive_slink: to home' {
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

@test 'bl::recursive_slink: to root' {
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

@test 'bl::recursive_concat: to home' {
  (
    . "${DIST_PATH}/bl.bash"

    local -r from_dir=./fixtures/dir1
    local -r tmp_dir="$(mktemp -d)"
    local -r to_dir="${tmp_dir}/dir2"
    cp -r ./fixtures/dir2 "$tmp_dir"

    export var=dir1
    run bl::recursive_concat "$from_dir" "$to_dir"
    assert_success
    assert_output 'dir1
dir1
dir1'

   local -r concat_out='dir2
dir1'

   run cat "${to_dir}/.ssh/config"
   assert_output "$concat_out"

   run cat "${to_dir}/.gitconfig"
   assert_output "$concat_out"

   run cat "${to_dir}/.inputrc"
   assert_output "$concat_out"
  )
}

@test 'bl::recursive_concat: to root' {
  (
    . "${DIST_PATH}/bl.bash"

    local -r from_dir=./fixtures/dir1
    local -r tmp_dir="$(sudo mktemp -d)"
    local -r to_dir="${tmp_dir}/dir2"
    sudo cp -r ./fixtures/dir2 "$tmp_dir"

    export var=dir1
    run bl::recursive_concat "$from_dir" "$to_dir"
    assert_success
    assert_output 'dir1
dir1
dir1'

   local -r concat_out='dir2
dir1'

   run sudo cat "${to_dir}/.ssh/config"
   assert_output "$concat_out"

   run sudo cat "${to_dir}/.gitconfig"
   assert_output "$concat_out"

   run sudo cat "${to_dir}/.inputrc"
   assert_output "$concat_out"
  )
}
