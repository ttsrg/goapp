#!/bin/bash
set -e # fail on any error
set -u # treat unset variables as errors

# ======[ Trap Errors ]======#
set -E # let shell functions inherit ERR trap

# Trap non-normal exit signals:
# 1/HUP, 2/INT, 3/QUIT, 15/TERM, ERR
trap err_handler 1 2 3 15 ERR
function err_handler {
local exit_status=${1:-$?}
logger -s -p "syslog.err" -t  "calc-web.deb script '$0' error code $exit_status (line $BASH_LINENO: '$BASH_COMMAND')"
exit $exit_status
}


export  dpath=web-calc
#mkdir -p  $dpath/DEBIAN $dpath/usr/bin
mkdir -p $dpath $dpath/DEBIAN $dpath/usr/bin $dpath/opt/goapp/ $dpath/etc/systemd/system


echo -e "Package: web-calc\nVersion: 1.0-1\nDepends: dpkg, golang-go, fakeroot, lintian\nMaintainer: ttserg\nDescription: web calc\nArchitecture: any"  > DEBIAN/control
echo -e "/opt/goapp"  > $dpath/DEBIAN/dirs
#systemctl stop web-calc
#cp ../build-go/build_go {usr/bin,opt/goapp/}
cp ../../build_go/build_go $dpath/usr/bin/
cp ../../build_go/build_go $dpath/opt/goapp/

#create web-calc.service
FILE=etc/systemd/system/web-calc.service

cat << EOF > $FILE
[Unit]
Description=Web Calc
After=network.target

[Service]
Type=simple
ExecStart=/opt/goapp/build_go

[Install]
Wanted.by=multi-user.target
EOF

md5deep -r . > $dpath/DEBIAN/md5sums

#sudo  systemctl daemon-reload
#sudo systemctl start web-calc
#md5

#fakeroot dpkg-deb --build deb
#mv deb.deb web-calc_1.0-1_all.deb
#lintian deb.deb web-calc_1.0-1_all.deb


exit 0
