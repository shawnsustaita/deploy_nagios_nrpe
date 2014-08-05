deploy_nagios_nrpe
==================

Deploy Nagios' NRPE on Linux clients.


description
===========
This script was created to facilitate installing the Nagios' NRPE plugins
and daemon on Linux clients.  The script configures xinetd to handle the
service.


Details
=======
The script was written to support Ubuntu and Redhat system but has only
been tested on Ubuntu 12.04 LTS and RHEL 5, so far.

The script creates the nagios user account.

The script installs the required SSL development libraries.

The script downloads, configures and installs the Nagios plugins.

The script installs and enables the xinetd service.

The script downloads, configures and installs the NRPE daemon.

The script installs an xinetd nrpe configuration.

The script installs an nrpe service (ie /etc/services).

The script downloads and installs a homegrown default nrpe.cfg
configuration.


Variables
=========
NAGIOS_UID  - This variable is used to set the uid/gid for the nagios account.
BUILD_DIR   - This variable is used to change directory to a specific build dir.
PLUGINS_URL - This variable is used to fetch a specific nagios-plugins tarball.
PLUGINS_OPT - This variable is passed to the nagios-plugins configure script.
NRPE_URL    - This variable is used to fetch a specific nrpe tarball.
NRPE_OPT    - This variable is passed to the nrpe configure script.
NRPE_CFG    - This variable is used to download a default nrpe.cfg.
NRPE_DIR    - This variable is used to download nrpe.cfg to specific directory.
NAGIOS_IP   - This variable is appended to the only_from directive in /etc/xinetd.d/nrpe.
              This variable is required.


Examples
========
ssh root@hostname 'wget http://deployscripthost/deploy_nagios_nrpe.txt -O- |
    key=value ... bash'

ssh root@hostname 'wget http://deployscripthost/deploy_nagios_nrpe.txt -O- |
    NAGIOS_IP=1.2.3.4 bash'

ssh root@hostname 'wget http://deployscripthost/deploy_nagios_nrpe.txt -O- |
    NAGIOS_IP='1.2.3.4 5.6.7.8'                        \
    BUILD_DIR=/tmp                                     \
    NRPE_OPTS=--with-ssl-lib=/usr/lib/x86_64-linux-gnu \
    NRPE_CFG=http://shawnito/nrpe.cfg                  \
    NRPE_DIR=/usr/local/nagios/etc                     \
    bash'


Assumptions
===========
wget is already installed on the systems.  root SSH key authentication is
already configured on the systems.
