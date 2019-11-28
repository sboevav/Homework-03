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
[vagrant@lvm ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.


STEP 3
[vagrant@lvm ~]$ sudo pvs
  PV         VG         Fmt  Attr PSize   PFree
  /dev/sda3  VolGroup00 lvm2 a--  <38.97g     0
  /dev/sdb              lvm2 ---   10.00g 10.00g

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
[vagrant@lvm ~]$ sudo su
[vagrant@lvm ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
...
xfsrestore: restore complete: 158 seconds elapsed
xfsrestore: Restore Status: SUCCESS


STEP 9 
[vagrant@lvm /]$ ls /mnt
bin   dev  home  lib64  mnt  proc  run   srv  tmp  vagrant
boot  etc  lib   media  opt  root  sbin  sys  usr  var

