#!/usr/bin/env sh

. "${HOOKS_DIR}/utils.lib.sh" >/dev/null 2>&1

log_file_name="liveness_probe"
log_file="/tmp/${log_file_name}.log"

# PDO-1432 - The /pa/* endpoints moved to /pa-was/*
heartbeat_endpoint="https://localhost:${PA_ENGINE_PORT}/pa-was/heartbeat.ping"

beluga_log "Starting PingAccess WAS Engine liveness probe.  Waiting for heartbeat endpoint at ${heartbeat_endpoint}" | tee -a "${log_file}"

get_url_response_code=$(curl -k \
  -s \
  -S \
  -w '%{response_code}' \
  --max-time 2 \
  -o /dev/null \
  "${heartbeat_endpoint}")
exit_code=$?

if test ${exit_code} -eq 0 && test 200 -eq ${get_url_response_code}; then
  beluga_log "PingAccess WAS Engine heartbeat endpoint ready" | tee -a "${log_file}"

  #limit to 1000 lines by creating  a tmp log file and replacing that with the original log_file
  belugacommon_limit_log_file_lines "${log_file}"

  exit 0
else
  beluga_error "PingAccess WAS Engine heartbeat endpoint NOT ready" | tee -a "${log_file}"

  #limit to 1000 lines by creating  a tmp log file and replacing that with the original log_file
  belugacommon_limit_log_file_lines "${log_file}"

  exit 1
fi