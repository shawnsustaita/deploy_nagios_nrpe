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
# This script was created to faciliate remote installs of the Nagios' NRPE
# client-side plugins and NRPE daemon.  The service is handled by xinetd.  The
# script only supports redhat and ubuntu distros.


### Variables
#
# NAGIOS_UID  - This variable is used to set the uid/gid for the nagios account.
# BUILD_DIR   - This variable is used to change directory to a specific build dir.
# PLUGINS_URL - This variable is used to fetch a specific nagios-plugins tarball.
# PLUGINS_OPT - This variable is passed to the nagios-plugins configure script.
# NRPE_URL    - This variable is used to fetch a specific nrpe tarball.
# NRPE_OPT    - This variable is passed to the nrpe configure script.
# NRPE_CFG    - This variable is used to download a default nrpe.cfg.
# NRPE_DIR    - This variable is used to download nrpe.cfg to specific directory.
# NAGIOS_IP   - This variable is appended to the only_from directive in /etc/xinetd.d/nrpe.
#               This variable is required.


### Example
# ssh root@hostname 'wget -q http://host/deploy_nagios_nrpe.sh -O - | key=value ... bash; echo $?'
#
# ssh root@hostname 'wget -q http://host/deploy_nagios_nrpe.sh -O - | NAGIOS_IP="10.0.0.2" NRPE_OPTS="--with-ssl-lib=/usr/lib/x86_64-linux-gnu" bash; echo $?'
#
# dsh -g nrpe_clients 'wget -q http://host/deploy_nagios_nrpe.sh -O - | NAGIOS_IP="10.0.0.2 10.0.0.3" bash; echo $?'


### Setup shell environment
set -e  # Exit if a command exits with a non-zero status
shopt -s nocasematch


### Change to build directory
[ -n "$BUILD_DIR" ] && cd "$BUILD_DIR"


### Do work in subshell
### Subshell facilitates logging
### ie  ( commands ) &> logfile
(

    echo "Script started at $( date )."
    echo


    ### Setup vars
    DATE=$( date +%Y%m%d )
    MYDISTRO=$( lsb_release -i )
    [ -n "$PLUGINS_URL" ] || PLUGINS_URL='http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz'
    [ -n "$NRPE_URL"    ] || NRPE_URL='http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz/download'


    ### Validate distro
    [[ $MYDISTRO =~ ubuntu ]] || [[ $MYDISTRO =~ redhat ]] || {
        echo 'Unsupported distro.'
        exit 1
    }
    
    
    ### Create nagios user, if missing (should be locked by default)
    grep -q '^nagios:' /etc/passwd || [ -n "$NAGIOS_UID" ] && useradd -u "$NAGIOS_UID" -M nagios || useradd -M nagios
    
    
    ### Install libssl, if missing
    [[ $MYDISTRO =~ redhat ]] && [[ ! $( rpm -q openssl-devel ) ]] && yum -y install openssl-devel
    [[ $MYDISTRO =~ ubuntu ]] && [[ ! $( dpkg -L libssl-dev   ) ]] && apt-get -y install libssl-dev
    
    
    ### Download, build and install Plugins
    wget -q -T 30 "$PLUGINS_URL" -O - | tar xzf -
    (
        cd nagios-plugins-2.0.3
        ./configure $PLUGINS_OPTS
        make
        make install
    )
    
    
    ### Install xinetd, if missing
    [[ $MYDISTRO =~ redhat ]] && [[ ! $( which xinetd ) ]] && yum -y install xinetd     && chkconfig xinetd on
    [[ $MYDISTRO =~ ubuntu ]] && [[ ! $( which xinetd ) ]] && apt-get -y install xinetd && update-rc.d xinetd defaults
    
    
    ### Download, build and install NRPE daemon
    wget -q -T 30 "$NRPE_URL" -O - | tar xzf -
    (
        cd nrpe-2.15
        ./configure $NRPE_OPTS
        make all
        make install-plugin
        make install-daemon
        make install-daemon-config
        make install-xinetd
    )

    
    ### Adjust NRPE service to accept connections from nagios server
    perl -i -pe "s/127.0.0.1/127.0.0.1 $NAGIOS_IP/" /etc/xinetd.d/nrpe
    
    
    ### Adjust services file
    grep -qi -e '^nrpe\b' -e '\b5666/tcp\b' /etc/services || echo -e 'nrpe\t\t5666/tcp\t\t\t# Nagios NRPE' >> /etc/services
    
    
    ### Start/Restart xinetd
    /etc/init.d/xinetd restart


    ### Deploy default nrpe.cfg
    [ -n "$NRPE_CFG" ] && [ -n "$NRPE_DIR" ] && wget -q -T 30 -N -P "$NRPE_DIR" "$NRPE_CFG"
    [ -n "$NRPE_CFG" ] && [ -z "$NRPE_DIR" ] && wget -q -T 30 -N "$NRPE_CFG"
    

    echo
    echo "Script ended at $( date )."
    
) &> deploy_nagios_nrpe.sh.out

