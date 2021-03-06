#!/bin/bash
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#

set -e

unset http_proxy https_proxy all_proxy no_proxy

echo "INFO: copying nova config files to /etc/nova"
cp -v /nova-etc/* /etc/nova

# export the env we get from kubernetes - not really required, as we source the corresponding script
export NOVA_DB_PURGE_DRY_RUN
export NOVA_DB_PURGE_MAX_NUMBER
export NOVA_DB_PURGE_OLDER_THAN

# we run an endless loop to run the script periodically
echo "INFO: starting a loop to periodically run the nanny jobs for the nova db"
while true; do
  if [ "$NOVA_QUOTA_SYNC_ENABLED" = "True" ] || [ "$NOVA_QUOTA_SYNC_ENABLED" = "true" ]; then
    echo "INFO: sync nova quotas"
    /var/lib/kolla/venv/bin/python /scripts/nova-quota-sync.py --all --auto_sync
  fi
  if [ "$NOVA_DB_PURGE_ENABLED" = "True" ] || [ "$NOVA_DB_PURGE_ENABLED" = "true" ]; then
    echo "INFO: purge old deleted instances from the nova db"
    if [ "$NOVA_DB_PURGE_DRY_RUN" = "true" ]; then
      echo -n "INFO: dry run mode only - "
      DRY_RUN="--dry-run"
    else
      echo -n "INFO: "
    fi
    echo -n "purging at max $NOVA_DB_PURGE_MAX_NUMBER deleted instances older than $NOVA_DB_PURGE_OLDER_THAN days from the nova db - "
    echo -n `date`
    echo -n " - "
    /var/lib/kolla/venv/bin/nova-manage db purge_deleted_instances $DRY_RUN --older-than $NOVA_DB_PURGE_OLDER_THAN --max-number $NOVA_DB_PURGE_MAX_NUMBER
  fi
  echo "INFO: waiting $NOVA_NANNY_INTERVAL minutes before starting the next loop run"
  sleep $(( 60 * $NOVA_NANNY_INTERVAL ))
done
