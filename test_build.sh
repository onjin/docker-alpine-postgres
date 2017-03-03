#!/bin/bash

set -e

ALL_VERSIONS="9.1,9.2,9.3,9.4,9.5,9.6"


# local variables
TEST_VERSIONS=${ALL_VERSIONS}

function usage() {
  echo "Usage: $0 [--help] [-t <comma seprated versions; f.i. 9.1,9.2]"
}

function test_build() {
  version=$1
  log=.build-${version}.log

  BUILD_OK=YES
  RUN_OK=YES

  echo  -n " - testing ${version} # "
  echo -n "Building: "
  echo -n " (Log file: ${log}) "
  docker build -t alpine-postgres:${version} ${version} > ${log} 2>&1 || BUILD_OK=NO

  if [ ${BUILD_OK} == YES ]; then
    echo -n "Build success"
  else
    echo -n "Build FAILED"
  fi

  echo -n " | "

  echo -n "Running: "
  docker run --rm -it -u postgres alpine-postgres:${version} pg_ctl --help >> ${log} 2>&1 || RUN_OK=NO

  if [ ${RUN_OK} == YES ]; then
    echo -n "Run success"
  else
    echo -n "Run FAILED"
  fi
  echo

}
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -t|--test-versions)
      TEST_VERSIONS="$2"
      shift # past argument
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # unknown option
      ;;
  esac
  shift # past argument or value
done

echo "Test versions: ${TEST_VERSIONS}"
if [ ! -z ${TEST_VERSIONS} ]; then
  IFS=","
  for v in ${TEST_VERSIONS}; do
    test_build $v
  done
fi
