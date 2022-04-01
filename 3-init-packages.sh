#!/bin/bash

wget_cmd() {
	wget --no-check-certificate --timeout 15 -4 --tries=5 $* || exit 1
}

mkdir -p downloads && cd downloads
{
	if [ ! -f 1.1-17.10.30-release.tar.gz ]
	then
		wget_cmd http://typecho.org/downloads/1.1-17.10.30-release.tar.gz
	fi
} &
{
	if [ ! -f ttyd.armhf ]
	then
		wget_cmd https://git.slitaz.workers.dev/tsl0922/ttyd/releases/download/1.6.3/ttyd.armhf
	fi
} &
{
	if [ ! -f AriaNg-1.2.3.zip ]
	then
		wget_cmd https://git.slitaz.workers.dev/mayswind/AriaNg/releases/download/1.2.3/AriaNg-1.2.3.zip
	fi
} &
wait
cd -

# blog & html
mkdir -p rootfs/var/www/html/files rootfs/etc/nginx/sites-available
tar -zxvf downloads/1.1-17.10.30-release.tar.gz -C rootfs/var/www/html > /dev/null 2>&1
mkdir -p rootfs/home/ubuntu/files
cd rootfs/var/www/html
mv build blog
chmod 777 -R blog
mv index.nginx-debian.html index3.html
ln -s /home/ubuntu/files ./files/home
cd -
cp pre_files/wiki/nginx_default rootfs/etc/nginx/sites-available/default
cp pre_files/wiki/index.html rootfs/var/www/html
cp pre_files/wiki/index2.html rootfs/var/www/html
cp pre_files/wiki/{kms.html,teasiu-wx.jpg,ec6108v9.jpg} rootfs/var/www/html/

cp pre_files/h5ai/{_h5ai.footer.md,_h5ai.header.html} rootfs/var/www/html/files
cp pre_files/h5ai/_h5ai.footer2.md rootfs/home/ubuntu/files/_h5ai.footer.md
tar -zxvf pre_files/h5ai/h5ai.tar.gz -C rootfs/var/www/html/files > /dev/null 2>&1

cat <<EOT > rootfs/var/www/html/info.php
<?php
phpinfo();
?>
EOT

# transmission
mkdir -p rootfs/usr/share/transmission/web rootfs/etc/transmission-daemon
mv -f rootfs/usr/share/transmission/web/index.html rootfs/usr/share/transmission/web/index.original.html
tar -zxvf pre_files/transmission/tr-web-control.tar.gz -C rootfs/usr/share/transmission/web > /dev/null 2>&1
cp -a pre_files/transmission/tr-settings.json rootfs/etc/transmission-daemon/settings.json

# ttyd
cp -a pre_files/ttyd.service rootfs/etc/systemd/system
chmod 644 rootfs/etc/systemd/system/ttyd.service
cp -a downloads/ttyd.armhf rootfs/usr/bin/ttyd
chmod +x rootfs/usr/bin/ttyd

# nfs-kernel-server
cat <<EOT > rootfs/etc/exports
/home/ubuntu/downloads *(rw,sync,no_root_squash,no_subtree_check)
EOT

# frpc
mkdir -p rootfs/etc/frp
cp pre_files/frpc/frpc rootfs/usr/bin
chmod +x rootfs/usr/bin/frpc
cp pre_files/frpc/frpc.ini rootfs/etc/frp
cp pre_files/frpc/frpc.service rootfs/etc/systemd/system
chmod 644 rootfs/etc/systemd/system/frpc.service

# aria2
mkdir -p rootfs/home/ubuntu/downloads rootfs/var/www/html/ariang rootfs/usr/local/aria2
chmod -R 777 rootfs/home/ubuntu/downloads
chown nobody:nogroup rootfs/home/ubuntu/downloads
unzip -o -q downloads/AriaNg-1.2.3.zip -d rootfs/var/www/html/ariang
touch rootfs/usr/local/aria2/aria2.session
chmod 777 rootfs/usr/local/aria2/aria2.session
cp -a pre_files/aria2.conf rootfs/usr/local/aria2
cp -a pre_files/aria2c.service rootfs/etc/systemd/system
chmod 644 rootfs/etc/systemd/system/aria2c.service

# v2ray
cp -a pre_files/install-v2ray.sh rootfs/usr/bin
chmod +x rootfs/usr/bin/install-v2ray.sh

# teslamate
cp -a pre_files/install-teslamate1.sh rootfs/usr/bin
chmod +x rootfs/usr/bin/install-teslamate1.sh

# dockers
cp -a pre_files/install-portainer.sh rootfs/usr/bin
cp -a pre_files/wiki/install-portainer.php rootfs/var/www/html
cp -a pre_files/install-qinglong.sh rootfs/usr/bin
cp -a pre_files/wiki/install-qinglong.php rootfs/var/www/html
chmod +x rootfs/usr/bin/install-portainer.sh
chmod +x rootfs/usr/bin/install-qinglong.sh

# samba
cp -a pre_files/install-samba.sh rootfs/usr/bin
cp -a pre_files/wiki/install-samba.php rootfs/var/www/html
chmod +x rootfs/usr/bin/install-samba.sh

# choose mv100 or mv200
echo "
1. mv100
2. mv200
3. mv300
"
while :; do
read -p "你想要定制哪个版本？ " CHOOSE
case $CHOOSE in
	1)
		bootargs="mv100"
	break
	;;
	2)
		bootargs="mv200"
	break
	;;
	3)
		bootargs="mv300"
	break
	;;
esac
done

cp -a pre_files/bootargs4-$bootargs.bin rootfs/usr/bin/bootargs4.bin
cp -a pre_files/boot4.sh rootfs/usr/bin/recoverbackup
chmod 777 rootfs/usr/bin/recoverbackup
echo "hi3798$bootargs" > rootfs/etc/hostname

# web2
cp -a pre_files/wiki/nginx_any168 rootfs/etc/nginx/sites-available/nginx_any168
cp -a pre_files/wiki/{favicon.ico,zhinan.html,ftp.html} rootfs/var/www/html/
cp -a pre_files/wiki/{css,img,js,fonts,images} rootfs/var/www/html/

# webdav
cp -a pre_files/wiki/nginx_webdav rootfs/etc/nginx/sites-available/nginx_webdav
cp -a pre_files/wiki/passwords.list rootfs/etc/nginx/
mkdir -p rootfs/home/ubuntu/webdav
echo "/home/ubuntu/webdav/" > rootfs/home/ubuntu/webdav/这是一个测试文档.txt

# gitweb
cp -a pre_files/install-gitweb.sh rootfs/usr/bin
chmod +x rootfs/usr/bin/install-gitweb.sh
mkdir -p rootfs/usr/share/bak
cp -a pre_files/wiki/gitweb rootfs/usr/share/bak

# others
cp -a pre_files/client-mode rootfs/home/ubuntu/
chmod 777 -R pre_files/sbin
cp -a pre_files/sbin/* rootfs/sbin
cp -a pre_files/profile.d/99-helloworld.sh rootfs/etc/profile.d
chmod 777 -R rootfs/etc/profile.d
sed -i "s/ports.ubuntu.com/mirrors.aliyun.com/g" rootfs/etc/apt/sources.list

# html-php
sed -i "404c security.limit_extensions = .php .php3 .php4 .php5 .php7 .html" rootfs/etc/php/7.4/fpm/pool.d/www.conf
echo "$(date +%Y%m%d)" > rootfs/etc/nasversion

cp -a pre_files/vsftpd.conf rootfs/etc/

# end
cat << EOF | chroot rootfs
systemctl enable ttyd
systemctl enable aria2c.service
systemctl enable frpc
ln -s /etc/nginx/sites-available/nginx_any168 /etc/nginx/sites-enabled/nginx_any168
ln -s /etc/nginx/sites-available/nginx_webdav /etc/nginx/sites-enabled/nginx_webdav
EOF
