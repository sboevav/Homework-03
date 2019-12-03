Script started on Thu 28 Nov 2019 05:09:19 PM UTC


STEP 1
[vagrant@lvm ~]$ sudo yum install xfsdump
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.sale-dedic.com
 * extras: mirror.corbina.net
 * updates: mirror.corbina.net
base                                                     | 3.6 kB     00:00
extras                                                   | 2.9 kB     00:00
updates                                                  | 2.9 kB     00:00
Resolving Dependencies
--> Running transaction check
---> Package xfsdump.x86_64 0:3.1.7-1.el7 will be installed
--> Processing Dependency: attr >= 2.0.0 for package: xfsdump-3.1.7-1.el7.x86_64
--> Running transaction check
---> Package attr.x86_64 0:2.4.46-13.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================
 Package          Arch            Version                   Repository     Size
================================================================================
Installing:
 xfsdump          x86_64          3.1.7-1.el7               base          308 k
Installing for dependencies:
 attr             x86_64          2.4.46-13.el7             base           66 k

Transaction Summary
================================================================================
Install  1 Package (+1 Dependent package)

Total download size: 374 k
Installed size: 1.1 M
Is this ok [y/d/N]: y
Downloading packages:
attr-2.4.46-13.el7.x86_64.rpm  FAILED
http://mirror.reconn.ru/centos/7.7.1908/os/x86_64/Packages/attr-2.4.46-13.el7.x86_64.rpm: [Errno 14] curl#6 - "Could not resolve host: mirror.reconn.ru; Unknown error"
Trying other mirror.
xfsdump-3.1.7-1.el7.x86_64.rpm FAILED
http://mirror.reconn.ru/centos/7.7.1908/os/x86_64/Packages/xfsdump-3.1.7-1.el7.x86_64.rpm: [Errno 14] curl#6 - "Could not resolve host: mirror.reconn.ru; Unknown error"
Trying other mirror.
(1/2): xfsdump-3.1.7-1.el7.x86_64.rpm                      | 308 kB   00:00
attr-2.4.46-13.el7.x86_64.rpm  FAILED
http://mirror.sale-dedic.com/centos/7.7.1908/os/x86_64/Packages/attr-2.4.46-13.el7.x86_64.rpm: [Errno 14] curl#6 - "Could not resolve host: mirror.sale-dedic.com; Unknown error"
Trying other mirror.
(2/2): attr-2.4.46-13.el7.x86_64.rpm                       |  66 kB   00:15
--------------------------------------------------------------------------------
Total                                              7.9 kB/s | 374 kB  00:47
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : attr-2.4.46-13.el7.x86_64                                    1/2
  Installing : xfsdump-3.1.7-1.el7.x86_64                                   2/2
  Verifying  : attr-2.4.46-13.el7.x86_64                                    1/2
  Verifying  : xfsdump-3.1.7-1.el7.x86_64                                   2/2

Installed:
  xfsdump.x86_64 0:3.1.7-1.el7

Dependency Installed:
  attr.x86_64 0:2.4.46-13.el7

Complete!


STEP 2
[vagrant@lvm ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
+-sda1                    8:1    0    1M  0 part 
+-sda2                    8:2    0    1G  0 part /boot
L-sda3                    8:3    0   39G  0 part 
  +-VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  L-VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 


STEP 3
[vagrant@lvm ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.


STEP 4
[vagrant@lvm ~]$ sudo vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created


STEP 5
[vagrant@lvm ~]$ sudo lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.


STEP 6
[vagrant@lvm ~]$ sudo mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0


STEP 7
[vagrant@lvm ~]$ sudo mount /dev/vg_root/lv_root /mnt


STEP 8
[vagrant@lvm ~]$ cd /
[vagrant@lvm /]$ sudo su
[root@lvm /]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
...
xfsrestore: restore complete: 158 seconds elapsed
xfsrestore: Restore Status: SUCCESS


STEP 9
[root@lvm /]# ls /mnt
bin   dev  home  lib64  mnt  proc  run   srv  tmp  vagrant
boot  etc  lib   media  opt  root  sbin  sys  usr  var


STEP 10
[root@lvm /]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done


STEP 11
[root@lvm /]# chroot /mnt/


STEP 12
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done


STEP 13
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
...
*** Creating image file ***
*** Creating microcode section ***
*** Created microcode section ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***


STEP 14
[root@lvm boot]# cat /boot/grub2/grub.cfg
#
# DO NOT EDIT THIS FILE
#
# It is automatically generated by grub2-mkconfig using templates
# from /etc/grub.d and settings from /etc/default/grub
#
...
### BEGIN /etc/grub.d/10_linux ###
menuentry 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-862.2.3.el7.x86_64-advanced-8c74fbf7-9a6d-40f2-9333-d9b4146e8635' {
	load_video
	set gfxpayload=keep
	insmod gzio
	insmod part_msdos
	insmod xfs
	set root='hd0,msdos2'
	if [ x$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos2 --hint-efi=hd0,msdos2 --hint-baremetal=ahci0,msdos2  570897ca-e759-4c81-90cf-389da6eee4cc
	else
	  search --no-floppy --fs-uuid --set=root 570897ca-e759-4c81-90cf-389da6eee4cc
	fi
	linux16 /vmlinuz-3.10.0-862.2.3.el7.x86_64 root=/dev/mapper/vg_root-lv_root ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VolGroup00/LogVol00 rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet 
	initrd16 /initramfs-3.10.0-862.2.3.el7.x86_64.img
}
if [ "x$default" = 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' ]; then default='Advanced options for CentOS Linux>CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)'; fi;
### END /etc/grub.d/10_linux ###
...


STEP 15
[root@lvm boot]# cat /etc/default/grub
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VolGroup00/LogVol00 rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet"
GRUB_DISABLE_RECOVERY="true"


STEP 16
[root@lvm boot]# vi /etc/default/grub


STEP 17
[root@lvm boot]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done


STEP 18
[root@lvm boot]# cat /boot/grub2/grub.cfg
#
# DO NOT EDIT THIS FILE
#
# It is automatically generated by grub2-mkconfig using templates
# from /etc/grub.d and settings from /etc/default/grub
#
...
### BEGIN /etc/grub.d/10_linux ###
menuentry 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-862.2.3.el7.x86_64-advanced-8c74fbf7-9a6d-40f2-9333-d9b4146e8635' {
	load_video
	set gfxpayload=keep
	insmod gzio
	insmod part_msdos
	insmod xfs
	set root='hd0,msdos2'
	if [ x$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos2 --hint-efi=hd0,msdos2 --hint-baremetal=ahci0,msdos2  570897ca-e759-4c81-90cf-389da6eee4cc
	else
	  search --no-floppy --fs-uuid --set=root 570897ca-e759-4c81-90cf-389da6eee4cc
	fi
	linux16 /vmlinuz-3.10.0-862.2.3.el7.x86_64 root=/dev/mapper/vg_root-lv_root ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=vg_root/lv_root rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet 
	initrd16 /initramfs-3.10.0-862.2.3.el7.x86_64.img
}
if [ "x$default" = 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' ]; then default='Advanced options for CentOS Linux>CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)'; fi;
### END /etc/grub.d/10_linux ###
...


STEP 19
[root@lvm boot]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk 
+-sda1                    8:1    0    1M  0 part 
+-sda2                    8:2    0    1G  0 part /boot
L-sda3                    8:3    0   39G  0 part 
  +-VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  
  L-VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk 
L-vg_root-lv_root       253:2    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0    1G  0 disk 


STEP 20
[root@lvm boot]# exit
