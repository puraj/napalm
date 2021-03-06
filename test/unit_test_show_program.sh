#!/bin/bash

setUp() {
  . '../bin/libnapalm'

  NAPALM_PROGRAMS_DIR=`mktemp -d`
  pd=$NAPALM_PROGRAMS_DIR # alias to reduce character count
}

tearDown() {
  rm -rf $pd
}

testShowProgramWithNameAndVersionNotInstalled() {
  local msg=`show_program_with_name_and_version foo 1.3 2>&1`
  assertEquals 'Not installed: foo 1.3' "$msg"
}

testShowProgramWithNameAndVersionInstalledButNotActive() {
  local prog=$pd/foo-1.3
  mkdir -p $prog

  local msg=`show_program_with_name_and_version foo 1.3`
  assertEquals "   $prog" "$msg"
}

testShowProgramWithNameAndVersionInstalledButNotActiveLinkPointsToSomethingElse() {
  local prog=$pd/foo-1.3
  mkdir -p $prog
  ln -s /tmp $pd/foo

  local msg=`show_program_with_name_and_version foo 1.3`
  assertEquals "   $prog" "$msg"
}

testShowProgramWithNameAndVersionInstalledAndActive() {
  local prog=$pd/foo-1.3
  mkdir -p $prog
  ln -s ${prog} $pd/foo

  local msg=`show_program_with_name_and_version foo 1.3`
  assertEquals " * $prog" "$msg"
}


testShowProgramWithNameNone() {
  local msg=`show_program_with_name foo 2>&1`
  assertEquals "Not installed: foo" "$msg"
}

testShowProgramWithNameNonExistentDirectory() {
  NAPALM_PROGRAMS_DIR='/non/existent'
  local msg=`show_program_with_name foo 2>&1`
  assertEquals "Not installed: foo" "$msg"
}

testShowProgramWithNameNoLink() {
  mkdir -p $pd/foo-1.{3,5}

  local msg=`show_program_with_name foo`
  local expected=`echo -e "   $pd/foo-1.3\n   $pd/foo-1.5"`
  assertEquals "$expected" "$msg"
}

testShowProgramWithNameLink() {
  mkdir -p $pd/foo-1.{3,5}
  ln -s $pd/foo-1.5 $pd/foo

  local msg=`show_program_with_name foo`
  local expected=`echo -e "   $pd/foo-1.3\n * $pd/foo-1.5"`
  assertEquals "$expected" "$msg"
}

testShowProgramWithNameMorePrograms() {
  mkdir -p $pd/foo-1.3
  mkdir -p $pd/bar-2.1
  mkdir -p $pd/bar-2.2-b5

  local msg=`show_program_with_name foo`
  assertEquals "   $pd/foo-1.3" "$msg"
}


testShowProgramAll() {
  local msg=`show_program_all 2>&1`
  assertEquals "Nothing installed" "$msg"
}

testShowProgramAllNonExistentDirectory() {
  NAPALM_PROGRAMS_DIR='/non/existent'
  local msg=`show_program_all 2>&1`
  assertEquals "Nothing installed" "$msg"
}

testShowProgramAllMixed() {
  mkdir -p $pd/foo-1.{3,5}
  ln -s $pd/foo-1.5 $pd/foo
  mkdir -p $pd/bar-2.0.1
  ln -s $pd/bar-2.0.1 $pd/bar
  mkdir -p $pd/baz-0.5-rc1

  local msg=`show_program_all`
  local expected=`cat << EOF
 * $pd/bar-2.0.1
   $pd/baz-0.5-rc1
   $pd/foo-1.3
 * $pd/foo-1.5
EOF`
  assertEquals "$expected" "$msg"
}


testShowProgramArgumentsNameAndVersion() {
  local msg=`show_program foo 1.3 2>&1`
  assertEquals "Not installed: foo 1.3" "$msg"
}

testShowProgramArgumentName() {
  local msg=`show_program foo 2>&1`
  assertEquals "Not installed: foo" "$msg"
}

testShowProgramNoArguments() {
  local msg=`show_program 2>&1`
  assertEquals "Nothing installed" "$msg"
}

testShowProgramProgramsDirNotExists() {
  NAPALM_PROGRAMS_DIR="/non/existent"
  local msg=`show_program foo 2>&1; assertEquals 1 $?`
  assertEquals "Not installed: foo" "$msg"
}

testShowProgramProgramsDirNotExistsWithVersion() {
  NAPALM_PROGRAMS_DIR="/non/existent"
  local msg=`show_program foo 1.3 2>&1; assertEquals 1 $?`
  assertEquals "Not installed: foo 1.3" "$msg"
}


testCountProgramsNotInstalled() {
  local count=`count_programs foo`
  assertEquals "0" "$count"
}

testCountProgramsInstalledOne() {
  mkdir -p $pd/foo-1.3

  local count=`count_programs foo`
  assertEquals "1" "$count"
}

testCountProgramsInstalledTwo() {
  mkdir -p $pd/foo-1.{3,7}

  local count=`count_programs foo`
  assertEquals "2" "$count"
}


testGetActiveVersionNotInstalled() {
  local msg=`get_active_version foo`
  assertEquals "" "$msg"
}

testGetActiveVersionInstalledOne() {
  mkdir -p $pd/foo-1.3
  ln -s $pd/foo-1.3 $pd/foo

  local msg=`get_active_version foo`
  assertEquals "1.3" "$msg"
}

testGetActiveVersionInstalledTwo() {
  mkdir -p $pd/foo-1.{3,7}
  ln -s $pd/foo-1.7 $pd/foo

  local msg=`get_active_version foo`
  assertEquals "1.7" "$msg"
}


. shunit2
