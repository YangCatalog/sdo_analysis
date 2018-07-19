#!/bin/bash -e

# Copyright (c) 2018 Cisco and/or its affiliates.
# This software is licensed to you under the terms of the Apache License, Version 2.0 (the "License").
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# The code, technical concepts, and all information contained herein, are the property of Cisco Technology, Inc.
# and/or its affiliated entities, under various laws including copyright, international treaties, patent,
# and/or contract. Any use of the material herein must be in accordance with the terms of the License.
# All rights not expressly granted by the License are reserved.
# Unless required by applicable law or agreed to separately in writing, software distributed under the
# License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied.

source configure.sh

LOG=$LOGS/GenerateFiguresAndStats.log
echo "Starting" > $LOG
date >> $LOG

# Generate the statistics since the beginning and ftp the files
# the YANG-get-stats.py (without arguements) generates the full stats in json in /media/sf_ubuntu-share/www/stats/ :
# this is necessary so that the figures are up to date with today stats, and YANG-figures can pick those latest stats up
# the YANG-get-stats.py --days 5 doesn't generate the json file.
mkdir -p $WEB_PRIVATE/stats
YANG-get-stats.py >> $LOG  2>&1
YANG-get-stats.py --days 5 >> $LOG 2>&1
YANG-figures.py >> $LOG 2>&1

exit

# part 1: Generate the dependency figures
mkdir -p $WEB_PRIVATE/figures
cd $WEB_PRIVATE/figures
symd.py --draft $IETFDIR/YANG/ --rfc-repos $IETFDIR/YANG-rfc/ --graph >>$LOG 2>&1
mv modules.png modules-ietf.png
symd.py --recurse --draft $MODULES --rfc-repos $IETFDIR/YANG-rfc/ --graph >>$LOG 2>&1
mv modules.png modules-all.png
symd.py --recurse --draft $MODULES --rfc-repos $IETFDIR/YANG-rfc/ --sub-graph ietf-interfaces >>$LOG 2>&1
mv ietf-interfaces.png ietf-interfaces-all.png
symd.py --recurse --draft $IETFDIR/YANG/ --rfc-repos $IETFDIR/YANG-rfc/ --sub-graph ietf-interfaces >>$LOG 2>&1
symd.py --recurse --draft $IETFDIR/YANG/ --rfc-repos $IETFDIR/YANG-rfc/ --sub-graph ietf-routing >>$LOG 2>&1

echo "End of the script!" >> $LOG
date >> $LOG
