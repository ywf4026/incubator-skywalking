# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/awk -f

BEGIN {
    in_storage_section=0;
    in_storage_type_section=0;
}

{
    if (in_storage_section == 0) {
        in_storage_section=$0 ~ /^storage:$/
    } else {
        in_storage_section=$0 ~ /^(#|\s{2})/
    }

    if (in_storage_section == 1) {
        # in the storage: section now
        if (in_storage_type_section == 0) {
            if (ENVIRON["ES_VERSION"] ~ /^6.+/) {
                in_storage_type_section=$0 ~ /^#?\s+elasticsearch:$/
            } else if (ENVIRON["ES_VERSION"] ~ /^7.+/) {
                in_storage_type_section=$0 ~ /^#?\s+elasticsearch7:$/
            } else if (ENVIRON["STORAGE"] ~ /^mysql.*$/) {
                in_storage_type_section=$0 ~ /^#?\s+mysql:/
            } else if (ENVIRON["STORAGE"] ~ /^h2.*$/) {
                in_storage_type_section=$0 ~ /^#?\s+h2:$/
            } else if (ENVIRON["STORAGE"] ~ /^influx.*$/) {
                in_storage_type_section=$0 ~ /^#?\s+influx:$/
            }
        } else {
            in_storage_type_section=$0 ~ /^#?\s{4}/
        }
        if (in_storage_type_section == 1) {
            gsub("^#", "", $0)
            print
        } else {
            if ($0 !~ /^#/) {
                if ($0 ~ /^storage:$/) {
                    print
                } else {
                    print "#" $0
                }
            } else {
                print
            }
        }
    } else {
        print
    }
}

