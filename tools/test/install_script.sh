#!/bin/bash
# Copyright 2018-2020 CERN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Authors:
# - Vincent Garonne <vgaronne@gmail.com>, 2018
# - Mario Lassnig <mario.lassnig@cern.ch>, 2018-2019
# - Hannes Hansen <hannes.jakob.hansen@cern.ch>, 2018-2019
# - Thomas Beermann <thomas.beermann@cern.ch>, 2019
# - Benedikt Ziemons <benedikt.ziemons@cern.ch>, 2020
# - Mayank Sharma <mayank.sharma@cern.ch>, 2022

set -eo pipefail

echo "* Using $(which python) $(python --version 2>&1) and $(which pip) $(pip --version 2>&1)"

if [ "$SUITE" == "client" -o "$SUITE" == "client_syntax" ]; then
    cd /usr/local/src/rucio
    python setup_rucio_client.py install
    cp etc/docker/test/extra/rucio_client.cfg etc/rucio.cfg

elif [ "$SUITE" == "syntax" -o "$SUITE" == "docs" ]; then
    cd /usr/local/src/rucio
    cp etc/docker/test/extra/rucio_syntax.cfg etc/rucio.cfg

elif [ "$SUITE" == "votest" ]; then
    RUCIO_HOME=/opt/rucio
    VOTEST_HELPER=$RUCIO_HOME/tools/test/votest_helper.py
    VOTEST_CONFIG_FILE=$RUCIO_HOME/etc/docker/test/matrix_policy_package_tests.yml
    echo "VOTEST: Overriding policy section in rucio.cfg"
    python $VOTEST_HELPER --vo $POLICY --get-vo-config --file $VOTEST_CONFIG_FILE
    echo "VOTEST: Restarting httpd to load config"
    httpd -k restart
fi
