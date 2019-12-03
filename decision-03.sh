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




[vagrant@lvm ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdb                       8:16   0    2G  0 disk 
sdc                       8:32   0    1G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0   40G  0 disk 
├─sde1                    8:65   0    1M  0 part 
├─sde2                    8:66   0    1G  0 part /boot
└─sde3                    8:67   0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm  
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ lvremove dev/VolGroup00/LogVol00
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lvm/lvmetad.socket: access failed: Permission denied
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  "dev/VolGroup00/LogVol00": Invalid path for Logical Volume.
[vagrant@lvm ~]$ sudo lvremove dev/VolGroup00/LogVol00
  "dev/VolGroup00/LogVol00": Invalid path for Logical Volume.
[vagrant@lvm ~]$ sudo su
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
  Logical Volume "LogVol00" already exists in volume group "VolGroup00"
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol00 /mnt
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdb                       8:16   0    2G  0 disk 
sdc                       8:32   0    1G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0   40G  0 disk 
├─sde1                    8:65   0    1M  0 part 
├─sde2                    8:66   0    1G  0 part /boot
└─sde3                    8:67   0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0    8G  0 lvm  /mnt
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsrestore: using file dump (drive_simple) strategy
xfsrestore: version 3.1.7 (dump format 3.0)
xfsdump: version 3.1.7 (dump format 3.0)
xfsdump: level 0 dump of lvm:/
xfsdump: dump date: Tue Dec  3 12:27:19 2019
xfsdump: session id: 12786330-d254-4f0c-b53f-ccbca2d7716b
xfsdump: session label: ""
xfsrestore: searching media for dump
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 741162944 bytes
xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsrestore: examining media file 0
xfsrestore: dump description: 
xfsrestore: hostname: lvm
xfsrestore: mount point: /
xfsrestore: volume: /dev/mapper/vg_root-lv_root
xfsrestore: session time: Tue Dec  3 12:27:19 2019
xfsrestore: level: 0
xfsrestore: session label: ""
xfsrestore: media label: ""
xfsrestore: file system id: 8c74fbf7-9a6d-40f2-9333-d9b4146e8635
xfsrestore: session id: 12786330-d254-4f0c-b53f-ccbca2d7716b
xfsrestore: media id: 23dfd0f5-9aff-4060-9004-e8126dc299b9
xfsrestore: searching media for directory dump
xfsrestore: reading directories
xfsdump: dumping non-directory files
xfsrestore: 2723 directories and 23673 entries processed
xfsrestore: directory post-processing
xfsrestore: restoring non-directory files
xfsdump: ending media file
xfsdump: media file size 718103120 bytes
xfsdump: dump size (non-dir files) : 704901896 bytes
xfsdump: dump complete: 95 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 96 seconds elapsed
xfsrestore: Restore Status: SUCCESS
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# chroot /mnt/
[root@lvm /]# 
[root@lvm /]# 
[root@lvm /]# vi /etc/default/grub
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
[root@lvm /]# 
[root@lvm /]# 
[root@lvm /]# cat /boot/grub2/grub.cfg
#
# DO NOT EDIT THIS FILE
#
# It is automatically generated by grub2-mkconfig using templates
# from /etc/grub.d and settings from /etc/default/grub
#

### BEGIN /etc/grub.d/00_header ###
set pager=1

if [ -s $prefix/grubenv ]; then
  load_env
fi
if [ "${next_entry}" ] ; then
   set default="${next_entry}"
   set next_entry=
   save_env next_entry
   set boot_once=true
else
   set default="${saved_entry}"
fi

if [ x"${feature_menuentry_id}" = xy ]; then
  menuentry_id_option="--id"
else
  menuentry_id_option=""
fi

export menuentry_id_option

if [ "${prev_saved_entry}" ]; then
  set saved_entry="${prev_saved_entry}"
  save_env saved_entry
  set prev_saved_entry=
  save_env prev_saved_entry
  set boot_once=true
fi

function savedefault {
  if [ -z "${boot_once}" ]; then
    saved_entry="${chosen}"
    save_env saved_entry
  fi
}

function load_video {
  if [ x$feature_all_video_module = xy ]; then
    insmod all_video
  else
    insmod efi_gop
    insmod efi_uga
    insmod ieee1275_fb
    insmod vbe
    insmod vga
    insmod video_bochs
    insmod video_cirrus
  fi
}

terminal_output console
if [ x$feature_timeout_style = xy ] ; then
  set timeout_style=menu
  set timeout=1
# Fallback normal timeout code in case the timeout_style feature is
# unavailable.
else
  set timeout=1
fi
### END /etc/grub.d/00_header ###

### BEGIN /etc/grub.d/00_tuned ###
set tuned_params=""
set tuned_initrd=""
### END /etc/grub.d/00_tuned ###

### BEGIN /etc/grub.d/01_users ###
if [ -f ${prefix}/user.cfg ]; then
  source ${prefix}/user.cfg
  if [ -n "${GRUB2_PASSWORD}" ]; then
    set superusers="root"
    export superusers
    password_pbkdf2 root ${GRUB2_PASSWORD}
  fi
fi
### END /etc/grub.d/01_users ###

### BEGIN /etc/grub.d/10_linux ###
menuentry 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-862.2.3.el7.x86_64-advanced-035a6686-d5ec-4c32-a568-4285fe011304' {
	load_video
	set gfxpayload=keep
	insmod gzio
	insmod part_msdos
	insmod xfs
	set root='hd4,msdos2'
	if [ x$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root --hint-bios=hd4,msdos2 --hint-efi=hd4,msdos2 --hint-baremetal=ahci4,msdos2  570897ca-e759-4c81-90cf-389da6eee4cc
	else
	  search --no-floppy --fs-uuid --set=root 570897ca-e759-4c81-90cf-389da6eee4cc
	fi
	linux16 /vmlinuz-3.10.0-862.2.3.el7.x86_64 root=/dev/mapper/VolGroup00-LogVol00 ro no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto rd.lvm.lv=VolGroup00/LogVol00 rd.lvm.lv=VolGroup00/LogVol01 rhgb quiet 
	initrd16 /initramfs-3.10.0-862.2.3.el7.x86_64.img
}
if [ "x$default" = 'CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)' ]; then default='Advanced options for CentOS Linux>CentOS Linux (3.10.0-862.2.3.el7.x86_64) 7 (Core)'; fi;
### END /etc/grub.d/10_linux ###

### BEGIN /etc/grub.d/20_linux_xen ###
### END /etc/grub.d/20_linux_xen ###

### BEGIN /etc/grub.d/20_ppc_terminfo ###
### END /etc/grub.d/20_ppc_terminfo ###

### BEGIN /etc/grub.d/30_os-prober ###
### END /etc/grub.d/30_os-prober ###

### BEGIN /etc/grub.d/40_custom ###
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
### END /etc/grub.d/40_custom ###

### BEGIN /etc/grub.d/41_custom ###
if [ -f  ${config_directory}/custom.cfg ]; then
  source ${config_directory}/custom.cfg
elif [ -z "${config_directory}" -a -f  $prefix/custom.cfg ]; then
  source $prefix/custom.cfg;
fi
### END /etc/grub.d/41_custom ###
[root@lvm /]# 
[root@lvm /]# 
[root@lvm /]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  
sdb                       8:16   0    2G  0 disk 
sdc                       8:32   0    1G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0   40G  0 disk 
├─sde1                    8:65   0    1M  0 part 
├─sde2                    8:66   0    1G  0 part /boot
└─sde3                    8:67   0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0    8G  0 lvm  /
[root@lvm /]# 
[root@lvm /]# 
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
Executing: /sbin/dracut -v initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64 --force
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: nss-softokn ***
*** Including module: i18n ***
*** Including module: drm ***
*** Including module: plymouth ***
*** Including module: dm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 60-persistent-storage-dm.rules
Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** Constructing AuthenticAMD.bin ****
*** Store current command line parameters ***
*** Creating image file ***
*** Creating microcode section ***
*** Created microcode section ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# 




Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** Constructing AuthenticAMD.bin ****
*** Store current command line parameters ***
*** Creating image file ***
*** Creating microcode section ***
*** Created microcode section ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# clear

[root@lvm boot]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   10G  0 disk 
└─vg_root-lv_root       253:0    0   10G  0 lvm  
sdb                       8:16   0    2G  0 disk 
sdc                       8:32   0    1G  0 disk 
sdd                       8:48   0    1G  0 disk 
sde                       8:64   0   40G  0 disk 
├─sde1                    8:65   0    1M  0 part 
├─sde2                    8:66   0    1G  0 part /boot
└─sde3                    8:67   0   39G  0 part 
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0    8G  0 lvm  /
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# pvcreate /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# vgcreate vg_var /dev/sdc /dev/sdd
  Volume group "vg_var" successfully created
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# lvcreate -L 1G -m1 -n lv_var vg_var
  Insufficient free space: 514 extents needed, but only 510 available
[root@lvm boot]# lvcreate -L 990M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 992.00 MiB
  Logical volume "lv_var" created.
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
63488 inodes, 253952 blocks
12697 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=260046848
8 block groups
32768 blocks per group, 32768 fragments per group
7936 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

[root@lvm boot]# mount /dev/vg_var/lv_var /mnt
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# cp -aR /var/* /mnt/      # rsync -avHPSAX /var/ /mnt/
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# ls /tmp/oldvar
adm    db     games   kerberos  local  log   nis  preserve  spool  yp
cache  empty  gopher  lib       lock   mail  opt  run       tmp
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# umount /mnt
[root@lvm boot]# mount /dev/vg_var/lv_var /var
[root@lvm boot]# 
[root@lvm boot]# ls /var
adm    db     games   kerberos  local  log         mail  opt       run    tmp
cache  empty  gopher  lib       lock   lost+found  nis   preserve  spool  yp
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat May 12 18:50:26 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat May 12 18:50:26 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
UUID="fba107f8-4fb3-4ecf-bada-309408b5d61e" /var ext4 defaults 0 0
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# blkid | grep var: | awk '{print $2}'
UUID="fba107f8-4fb3-4ecf-bada-309408b5d61e"
[root@lvm boot]# 
[root@lvm boot]# 
[root@lvm boot]# exit
exit
[root@lvm vagrant]# 
[root@lvm vagrant]# reboot
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
aleksei@linux:~/linux/homework-03$ vagrant ssh lvm
Last login: Tue Dec  3 12:16:46 2019 from 10.0.2.2
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk 
├─sda1                     8:1    0    1M  0 part 
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk 
└─vg_root-lv_root        253:2    0   10G  0 lvm  
sdc                        8:32   0    2G  0 disk 
sdd                        8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
sde                        8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
[vagrant@lvm ~]$ clear

[vagrant@lvm ~]$ lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk 
├─sda1                     8:1    0    1M  0 part 
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk 
└─vg_root-lv_root        253:2    0   10G  0 lvm  
sdc                        8:32   0    2G  0 disk 
sdd                        8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
sde                        8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ lvremove /dev/vg_root/lv_root
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lvm/lvmetad.socket: access failed: Permission denied
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  /dev/mapper/control: open failed: Permission denied
  Failure to communicate with kernel device-mapper driver.
  Incompatible libdevmapper 1.02.146-RHEL7 (2018-01-22) and kernel driver (unknown version).
  /run/lock/lvm/V_vg_root:aux: open failed: Permission denied
  Can't get lock for vg_root
  Cannot process volume group vg_root
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ 
[vagrant@lvm ~]$ sudo su
^[[A^[[B
[root@lvm vagrant]# 
[root@lvm vagrant]# lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@lvm vagrant]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk 
├─sda1                     8:1    0    1M  0 part 
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk 
sdc                        8:32   0    2G  0 disk 
sdd                        8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0  253:3    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
sde                        8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm  
│ └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  992M  0 lvm  
  └─vg_var-lv_var        253:7    0  992M  0 lvm  /var
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# ls /home
vagrant
[root@lvm vagrant]# cd /home/vagrant
[root@lvm vagrant]# ls
[root@lvm vagrant]# cd -
/home/vagrant
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@lvm vagrant]# mkfs.xfs /dev/VolGroup00/LogVol_Home
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /mnt/
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# cp -aR /home/* /mnt/
[root@lvm vagrant]# 
[root@lvm vagrant]# ls /home
vagrant
[root@lvm vagrant]# ls /mnt/
vagrant
[root@lvm vagrant]# ls /mnt
vagrant
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# rm -rf /home/*
[root@lvm vagrant]# umount /mnt
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# mount /dev/VolGroup00/LogVol_Home /home/
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Sat May 12 18:50:26 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
/dev/mapper/VolGroup00-LogVol00 /                       xfs     defaults        0 0
UUID=570897ca-e759-4c81-90cf-389da6eee4cc /boot                   xfs     defaults        0 0
/dev/mapper/VolGroup00-LogVol01 swap                    swap    defaults        0 0
UUID="fba107f8-4fb3-4ecf-bada-309408b5d61e" /var ext4 defaults 0 0
UUID="dfb160c8-3f42-4ec0-a81c-3886d03ab704" /home xfs defaults 0 0
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# touch /home/file{1..20}
[root@lvm vagrant]# ls /home
file1   file12  file15  file18  file20  file5  file8
file10  file13  file16  file19  file3   file6  file9
file11  file14  file17  file2   file4   file7  vagrant
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home
sdb                          8:16   0   10G  0 disk 
sdc                          8:32   0    2G  0 disk 
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:4    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
sde                          8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvcreate -L 100M -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128.00 MiB
  Logical volume "home_snap" created.
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvcreate --help
  lvcreate - Create a logical volume

  Create a linear LV.
  lvcreate -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[    --type linear ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a striped LV (infers --type striped).
  lvcreate -i|--stripes Number -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a raid1 or mirror LV (infers --type raid1|mirror).
  lvcreate -m|--mirrors Number -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -R|--regionsize Size[m|UNIT] ]
	[    --mirrorlog core|disk ]
	[    --minrecoveryrate Size[k|UNIT] ]
	[    --maxrecoveryrate Size[k|UNIT] ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a raid LV (a specific raid level must be used, e.g. raid1).
  lvcreate --type raid -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -m|--mirrors Number ]
	[ -i|--stripes Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ -R|--regionsize Size[m|UNIT] ]
	[    --minrecoveryrate Size[k|UNIT] ]
	[    --maxrecoveryrate Size[k|UNIT] ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a raid10 LV.
  lvcreate -m|--mirrors Number -i|--stripes Number -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ -R|--regionsize Size[m|UNIT] ]
	[    --minrecoveryrate Size[k|UNIT] ]
	[    --maxrecoveryrate Size[k|UNIT] ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a COW snapshot LV of an origin LV.
  lvcreate -s|--snapshot -L|--size Size[m|UNIT] LV
	[ -l|--extents Number[PERCENT] ]
	[ -i|--stripes Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ -c|--chunksize Size[k|UNIT] ]
	[    --type snapshot ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a thin pool.
  lvcreate --type thin-pool -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -i|--stripes Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[    --thinpool LV_new ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --discards passdown|nopassdown|ignore ]
	[    --errorwhenfull y|n ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a cache pool.
  lvcreate --type cache-pool -L|--size Size[m|UNIT] VG
	[ -l|--extents Number[PERCENT] ]
	[ -H|--cache ]
	[ -c|--chunksize Size[k|UNIT] ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --cachemode writethrough|writeback|passthrough ]
	[    --cachepolicy String ]
	[    --cachesettings String ]
	[    --cachemetadataformat auto|1|2 ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a thin LV in a thin pool (infers --type thin).
  lvcreate -V|--virtualsize Size[m|UNIT] --thinpool LV_thinpool VG
	[ -T|--thin ]
	[    --type thin ]
	[    --discards passdown|nopassdown|ignore ]
	[    --errorwhenfull y|n ]
	[ COMMON_OPTIONS ]

  Create a thin LV that is a snapshot of an existing thin LV 
  (infers --type thin).
  lvcreate -s|--snapshot LV_thin
	[    --type thin ]
	[    --discards passdown|nopassdown|ignore ]
	[    --errorwhenfull y|n ]
	[ COMMON_OPTIONS ]

  Create a thin LV that is a snapshot of an external origin LV.
  lvcreate --type thin --thinpool LV_thinpool LV
	[ -T|--thin ]
	[ -c|--chunksize Size[k|UNIT] ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --discards passdown|nopassdown|ignore ]
	[    --errorwhenfull y|n ]
	[ COMMON_OPTIONS ]

  Create a thin LV, first creating a thin pool for it, 
  where the new thin pool is named by the --thinpool arg.
  lvcreate --type thin -V|--virtualsize Size[m|UNIT] -L|--size Size[m|UNIT] --thinpool LV_new
	[ -l|--extents Number[PERCENT] ]
	[ -T|--thin ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -i|--stripes Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --discards passdown|nopassdown|ignore ]
	[    --errorwhenfull y|n ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Create a cache LV, first creating a new origin LV, 
  then combining it with the existing cache pool named 
  by the --cachepool arg.
  lvcreate --type cache -L|--size Size[m|UNIT] --cachepool LV_cachepool VG
	[ -l|--extents Number[PERCENT] ]
	[ -H|--cache ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -i|--stripes Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --cachemode writethrough|writeback|passthrough ]
	[    --cachepolicy String ]
	[    --cachesettings String ]
	[    --cachemetadataformat auto|1|2 ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Common options for command:
	[ -a|--activate y|n|ay ]
	[ -A|--autobackup y|n ]
	[ -C|--contiguous y|n ]
	[ -M|--persistent y|n ]
	[ -j|--major Number ]
	[ -k|--setactivationskip y|n ]
	[ -K|--ignoreactivationskip ]
	[ -n|--name String ]
	[ -p|--permission rw|r ]
	[ -r|--readahead auto|none|Number ]
	[ -W|--wipesignatures y|n ]
	[ -Z|--zero y|n ]
	[    --addtag Tag ]
	[    --alloc contiguous|cling|cling_by_tags|normal|anywhere|inherit ]
	[    --ignoremonitoring ]
	[    --metadataprofile String ]
	[    --minor Number ]
	[    --monitor y|n ]
	[    --nosync ]
	[    --noudevsync ]
	[    --reportformat basic|json ]

  Common options for lvm:
	[ -d|--debug ]
	[ -h|--help ]
	[ -q|--quiet ]
	[ -v|--verbose ]
	[ -y|--yes ]
	[ -t|--test ]
	[    --commandprofile String ]
	[    --config String ]
	[    --driverloaded y|n ]
	[    --lockopt String ]
	[    --longhelp ]
	[    --profile String ]
	[    --version ]

  Use --longhelp to show all options and advanced commands.
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                               8:0    0   40G  0 disk 
├─sda1                            8:1    0    1M  0 part 
├─sda2                            8:2    0    1G  0 part /boot
└─sda3                            8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00         253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01         253:1    0  1.5G  0 lvm  [SWAP]
  ├─VolGroup00-LogVol_Home-real 253:8    0    2G  0 lvm  
  │ ├─VolGroup00-LogVol_Home    253:2    0    2G  0 lvm  /home
  │ └─VolGroup00-home_snap      253:10   0    2G  0 lvm  
  └─VolGroup00-home_snap-cow    253:9    0  128M  0 lvm  
    └─VolGroup00-home_snap      253:10   0    2G  0 lvm  
sdb                               8:16   0   10G  0 disk 
sdc                               8:32   0    2G  0 disk 
sdd                               8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0         253:3    0    4M  0 lvm  
│ └─vg_var-lv_var               253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0        253:4    0  992M  0 lvm  
  └─vg_var-lv_var               253:7    0  992M  0 lvm  /var
sde                               8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1         253:5    0    4M  0 lvm  
│ └─vg_var-lv_var               253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1        253:6    0  992M  0 lvm  
  └─vg_var-lv_var               253:7    0  992M  0 lvm  /var
[root@lvm vagrant]# rm -f /home/file{1..10}
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# ls /home
file11  file13  file15  file17  file19  vagrant
file12  file14  file16  file18  file20
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# umount /home
[root@lvm vagrant]# 
[root@lvm vagrant]# lvconvert --help
  lvconvert - Change logical volume layout

  Convert LV to linear.
  lvconvert --type linear LV
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert LV to striped.
  lvconvert --type striped LV
	[ -I|--stripesize Size[k|UNIT] ]
	[ -R|--regionsize Size[m|UNIT] ]
	[ -i|--interval Number ]
	[    --stripes Number ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert LV to raid or change raid layout 
  (a specific raid level must be used, e.g. raid1).
  lvconvert --type raid LV
	[ -m|--mirrors [+|-]Number ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ -R|--regionsize Size[m|UNIT] ]
	[ -i|--interval Number ]
	[    --stripes Number ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert LV to raid1 or mirror, or change number of mirror images.
  lvconvert -m|--mirrors [+|-]Number LV
	[ -R|--regionsize Size[m|UNIT] ]
	[ -i|--interval Number ]
	[    --mirrorlog core|disk ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert raid LV to change number of stripe images.
  lvconvert --stripes Number LV_raid
	[ -i|--interval Number ]
	[ -R|--regionsize Size[m|UNIT] ]
	[ -I|--stripesize Size[k|UNIT] ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert raid LV to change the stripe size.
  lvconvert -I|--stripesize Size[k|UNIT] LV_raid
	[ -i|--interval Number ]
	[ -R|--regionsize Size[m|UNIT] ]
	[ COMMON_OPTIONS ]

  Split images from a raid1 or mirror LV and use them to create a new LV.
  lvconvert --splitmirrors Number -n|--name LV_new LV_cache_mirror_raid1
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Split images from a raid1 LV and track changes to origin.
  lvconvert --splitmirrors Number --trackchanges LV_cache_raid1
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Merge LV images that were split from a raid1 LV.
  lvconvert --mergemirrors VG|LV_linear_raid|Tag ...
	[ COMMON_OPTIONS ]

  Convert LV to a thin LV, using the original LV as an external origin.
  lvconvert --type thin --thinpool LV LV_linear_striped_cache_raid
	[ -T|--thin ]
	[ -r|--readahead auto|none|Number ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -Z|--zero y|n ]
	[    --originname LV_new ]
	[    --poolmetadata LV ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --metadataprofile String ]
	[ COMMON_OPTIONS ]

  Convert LV to type cache.
  lvconvert --type cache --cachepool LV LV_linear_striped_thinpool_raid
	[ -H|--cache ]
	[ -Z|--zero y|n ]
	[ -r|--readahead auto|none|Number ]
	[ -c|--chunksize Size[k|UNIT] ]
	[    --cachemetadataformat auto|1|2 ]
	[    --cachemode writethrough|writeback|passthrough ]
	[    --cachepolicy String ]
	[    --cachesettings String ]
	[    --poolmetadata LV ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --metadataprofile String ]
	[ COMMON_OPTIONS ]

  Convert LV to type thin-pool.
  lvconvert --type thin-pool LV_linear_striped_cache_raid
	[ -I|--stripesize Size[k|UNIT] ]
	[ -r|--readahead auto|none|Number ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -Z|--zero y|n ]
	[    --stripes Number ]
	[    --discards passdown|nopassdown|ignore ]
	[    --poolmetadata LV ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --metadataprofile String ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Convert LV to type cache-pool.
  lvconvert --type cache-pool LV_linear_striped_raid
	[ -Z|--zero y|n ]
	[ -r|--readahead auto|none|Number ]
	[ -c|--chunksize Size[k|UNIT] ]
	[    --cachemetadataformat auto|1|2 ]
	[    --cachemode writethrough|writeback|passthrough ]
	[    --cachepolicy String ]
	[    --cachesettings String ]
	[    --poolmetadata LV ]
	[    --poolmetadatasize Size[m|UNIT] ]
	[    --poolmetadataspare y|n ]
	[    --metadataprofile String ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Separate and keep the cache pool from a cache LV.
  lvconvert --splitcache LV_thinpool_cache_cachepool
	[ COMMON_OPTIONS ]

  Merge thin LV into its origin LV.
  lvconvert --mergethin LV_thin ...
	[ COMMON_OPTIONS ]

  Merge COW snapshot LV into its origin.
  lvconvert --mergesnapshot LV_snapshot ...
	[ -i|--interval Number ]
	[ COMMON_OPTIONS ]

  Combine a former COW snapshot (second arg) with a former 
  origin LV (first arg) to reverse a splitsnapshot command.
  lvconvert --type snapshot LV LV_linear
	[ -s|--snapshot ]
	[ -c|--chunksize Size[k|UNIT] ]
	[ -Z|--zero y|n ]
	[ COMMON_OPTIONS ]

  Replace failed PVs in a raid or mirror LV. 
  Repair a thin pool. 
  Repair a cache pool.
  lvconvert --repair LV_thinpool_cache_cachepool_mirror_raid
	[ -i|--interval Number ]
	[    --usepolicies ]
	[    --poolmetadataspare y|n ]
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Replace specific PV(s) in a raid LV with another PV.
  lvconvert --replace PV LV_raid
	[ COMMON_OPTIONS ]
	[ PV ... ]

  Poll LV to continue conversion.
  lvconvert --startpoll LV_mirror_raid
	[ COMMON_OPTIONS ]

  Common options for command:
	[ -b|--background ]
	[ -f|--force ]
	[    --alloc contiguous|cling|cling_by_tags|normal|anywhere|inherit ]
	[    --noudevsync ]

  Common options for lvm:
	[ -d|--debug ]
	[ -h|--help ]
	[ -q|--quiet ]
	[ -v|--verbose ]
	[ -y|--yes ]
	[ -t|--test ]
	[    --commandprofile String ]
	[    --config String ]
	[    --driverloaded y|n ]
	[    --lockopt String ]
	[    --longhelp ]
	[    --profile String ]
	[    --version ]

  Use --longhelp to show all options and advanced commands.
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lvconvert --merge /dev/VolGroup00/home_snap
  Merging of volume VolGroup00/home_snap started.
  VolGroup00/LogVol_Home: Merged: 100.00%
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  
sdb                          8:16   0   10G  0 disk 
sdc                          8:32   0    2G  0 disk 
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:4    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
sde                          8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# mount /home
[root@lvm vagrant]# 
[root@lvm vagrant]# lsblk
NAME                       MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                          8:0    0   40G  0 disk 
├─sda1                       8:1    0    1M  0 part 
├─sda2                       8:2    0    1G  0 part /boot
└─sda3                       8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00    253:0    0    8G  0 lvm  /
  ├─VolGroup00-LogVol01    253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol_Home 253:2    0    2G  0 lvm  /home
sdb                          8:16   0   10G  0 disk 
sdc                          8:32   0    2G  0 disk 
sdd                          8:48   0    1G  0 disk 
├─vg_var-lv_var_rmeta_0    253:3    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_0   253:4    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
sde                          8:64   0    1G  0 disk 
├─vg_var-lv_var_rmeta_1    253:5    0    4M  0 lvm  
│ └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
└─vg_var-lv_var_rimage_1   253:6    0  992M  0 lvm  
  └─vg_var-lv_var          253:7    0  992M  0 lvm  /var
[root@lvm vagrant]# 
[root@lvm vagrant]# 
[root@lvm vagrant]# ls /home
file1   file12  file15  file18  file20  file5  file8
file10  file13  file16  file19  file3   file6  file9
file11  file14  file17  file2   file4   file7  vagrant
[root@lvm vagrant]# 

***************************************



