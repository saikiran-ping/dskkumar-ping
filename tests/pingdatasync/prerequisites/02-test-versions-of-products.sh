#!/bin/bash

CI_SCRIPTS_DIR="${SHARED_CI_SCRIPTS_DIR:-/ci-scripts}"
. "${CI_SCRIPTS_DIR}"/common.sh "${1}"


if skipTest "${0}"; then
  log "Skipping test ${0}"
  exit 0
fi

POD_NAME="pingdatasync-0"

testAlpineVersion() {
  log "Test: Verify Alpine Version"

  kubectl exec -n $PING_CLOUD_NAMESPACE $POD_NAME -c pingdirectory -- sh -c \
    'cat /etc/alpine-release | grep -q ${PRODUCT_ALPINE_VERSION}'
  assertEquals "Validation failed on alpine version" 0 $?
}

testProductVersion() {
  log "Test: Verify Product Version"

  kubectl exec -n $PING_CLOUD_NAMESPACE $POD_NAME -c pingdirectory -- sh -c \
    'status --version | head -n 1 | grep -q ${PRODUCT_VERSION}'
  assertEquals "Validation failed on product version" 0 $?
}

testJavaVersion() {
  log "Test: Verify Java Version"

  kubectl exec -n $PING_CLOUD_NAMESPACE $POD_NAME -c pingdirectory -- sh -c \
    'java -version 2>&1 | grep -q ${PRODUCT_JAVA_VERSION}'

  assertEquals "Validation failed on Java version" 0 $?
}


shift $#

. ${SHUNIT_PATH}