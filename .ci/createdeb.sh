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

###############################
dpath=web-calc
if  [ -e $dpath ]; then rm -rf $dpath; fi
#[[ -f $dpath* ]] &&  rm -f $dpath*
if ls -d $dpath* >/dev/null 2>&1; then rm -f $dpath*; fi

#sleep 3

#mkdir -p  $dpath/DEBIAN $dpath/usr/bin
mkdir -p $dpath $dpath/DEBIAN $dpath/usr/bin $dpath/opt/goapp/ $dpath/etc/systemd/system
echo -e "Package: web-calc\nVersion: $1\nDepends: dpkg, golang-go, fakeroot, lintian, ncdu\nMaintainer: ttserg\nSection: misc\nDescription: web calc\nArchitecture: all"  > $dpath/DEBIAN/control
#echo -e "#!/bin/bash\nsystemctl stop web-calc"  > $dpath/DEBIAN/preinst
echo -e "#!/bin/bash\necho "prerm"\n"  > $dpath/DEBIAN/prerm
echo -e "\nsystemctl stop web-calc\nsystemctl disable web-calc"  >> $dpath/DEBIAN/prerm
echo -e "#!/bin/bash\necho "postrm"\n"  > $dpath/DEBIAN/postrm
#echo -e "systemctl stop web-calc\nsystemctl disable web-calc\nsystemctl daemon-reload\necho alles\n"  >> $dpath/DEBIAN/postrm
echo -e "\nrm -r /etc/systemd/system/web-calc.service /opt/goapp\n/usr/bin/build_go\n"  >> $dpath/DEBIAN/postrm
echo -e "#!/bin/bash\nsystemctl daemon-reload\nsystemctl restart web-calc\nsystemctl enable web-calc"  > $dpath/DEBIAN/postinst

chmod 0555 $dpath/DEBIAN/postinst
chmod 0555 $dpath/DEBIAN/prerm
chmod 0555 $dpath/DEBIAN/postrm
# $dpath/DEBIAN/prerm
#chmod 0555  $dpath/DEBIAN/preinst

#cp build_go $dpath/usr/bin/
cp ../build_go $dpath/opt/goapp/

#create web-calc.service
FILE=$dpath/etc/systemd/system/web-calc.service
cat << EOF > $FILE
[Unit]
Description=Web Calc
After=network.target
[Service]
Type=simple
ExecStart=/opt/goapp/build_go
[Install]
WantedBy=multi-user.target
EOF

md5deep -r $dpath > $dpath/DEBIAN/md5sums

fakeroot dpkg-deb --build $dpath



mv $dpath.deb   "$dpath"_"$1".deb

#lintian deb.deb web-calc_1.0-1_all.deb

exit 0


###  rm -vf /var/lib/dpkg/info/web-calc.*
###   dpkg --remove --force-remove-reinstreq web-calc

