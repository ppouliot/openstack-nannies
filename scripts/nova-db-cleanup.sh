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

echo -n "INFO: cleaning up nova entities without a valid project in the nova db - "
date
if [ "$NOVA_DB_CLEANUP_DRY_RUN" = "True" ] || [ "$NOVA_DB_CLEANUP_DRY_RUN" = "true" ]; then
  DRY_RUN="--dry-run"
fi

export OS_USER_DOMAIN_NAME
export OS_PROJECT_NAME
export OS_PASSWORD
export OS_AUTH_URL
export OS_USERNAME
export OS_PROJECT_DOMAIN_NAME

/var/lib/kolla/venv/bin/python /scripts/db-cleanup.py $DRY_RUN --iterations $NOVA_DB_CLEANUP_ITERATIONS --interval $NOVA_DB_CLEANUP_INTERVAL --nova
