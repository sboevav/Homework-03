# stands-03-lvm

Стенд для домашнего занятия "Файловые системы и LVM"

# Решение

1. Установка пакета xfsdump для резервного копирования файловой системы XFS

sudo yum install xfsdump

2. Проверим текущие разделы

lsblk

3. Создадим физический раздел на основе диска sdb

sudo pvcreate /dev/sdb

4. Создадим группу физических разделов с именем vg_root на основе диска sdb

sudo vgcreate vg_root /dev/sdb

5. Создадим на основе группы vg_root логический раздел lv_root, используя всю доступную область

sudo lvcreate -n lv_root -l +100%FREE /dev/vg_root

6. Создадим на логическом разделе lv_root файловую систему

sudo mkfs.xfs /dev/vg_root/lv_root

7. Смонтируем логический раздел lv_root в /mnt

sudo mount /dev/vg_root/lv_root /mnt

8. Cкопируем все данные с раздела LogVol00 в раздел lv_root
(Примечание - копирование с указанием sudo не проходит, необходимо перейти в суперпользователя: sudo su)

xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt

9. Проверим все ли скопировалось в раздел lv_root

ls /mnt

10. Смонтируем часть файловой структуры в другой каталог, не удаляя при этом исходную точку монтирования

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

11. Сменим корневую директорию (/) на каталог /mnt

chroot /mnt/

12. Обновим  grub

[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg

13. Обновим образ initrd

[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done

14. Посмотрим на какой разделе у нас ссылается rd.lvm.lv

[root@lvm boot]# cat /boot/grub2/grub.cfg

15. Изменим содержимое файла конфигурации 

[root@lvm boot]# cat /etc/default/grub

16. Изменим файл конфигурации, переопределив rd.lvm.lv

[root@lvm boot]# vi /etc/default/grub

17. Обновим  grub

[root@lvm boot]# grub2-mkconfig -o /boot/grub2/grub.cfg

18. Посмотрим на какой раздел теперь у нас ссылается rd.lvm.lv

[root@lvm boot]# cat /boot/grub2/grub.cfg


19. Проверим новый рут

[root@lvm boot]# lsblk


20. Выходим 
[root@lvm boot]# exit





