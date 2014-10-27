#!/bin/bash


### Author:   Shawn Sustaita <shawn.sustaita@gmail.com>
### Source:   https://github.com/shawnsustaita/deploy_nagios_nrpe
### Date:     2014-08-07
### Version:  0.1.0


### License
# The MIT License (MIT)
# 
# Copyright (c) 2014 Shawn Sustaita
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



### Comments
#
# This script was created to faciliate deploying the Nagios NRPE's nrpe.cfg
# configuration file.


### Variables
# CONFIG_URL - URL of where to download the plugin.  (required)
# CONFIG_DIR - Directory of where to install the plugin.


### Example
# ssh root@hostname 'wget -q http://host/deploy_nrpe_plugin.sh -O - | CONFIG_URL="..." CONFIG_DIR="..." bash'


### Setup shell environment
set -e  # Exit if a command exits with a non-zero status

[ -n "$CONFIG_URL" ] || exit 1

CONFIG=$( echo "$CONFIG_URL" | perl -pe 's{^.*/}{}' )

[ -n "$CONFIG_DIR" ] && wget -q -T 30 -N -P "$CONFIG_DIR" "$CONFIG_URL"
[ -n "$CONFIG_DIR" ] || wget -q -T 30 -N -P /usr/local/nagios/etc "$CONFIG_URL"

[ -n "$CONFIG_DIR" ] && chmod 644 "${CONFIG_DIR}/${CONFIG}"
[ -n "$CONFIG_DIR" ] || chmod 644 "/usr/local/nagios/etc/${CONFIG}"

