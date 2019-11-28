# stands-03-lvm

Стенд для домашнего занятия "Файловые системы и LVM"

# Решение

1. Установка пакета xfsdump для резервного копирования файловой системы XFS
sudo yum install xfsdump

2. Создадим физический раздел на основе диска sdb
sudo pvcreate /dev/sdb

3. Создадим группу физических разделов с именем vg_root на основе диска sdb
sudo vgcreate vg_root /dev/sdb

4. Создадим на основе группы vg_root логический раздел lv_root, используя всю доступную область
sudo lvcreate -n lv_root -l +100%FREE /dev/vg_root

5. Создадим на логическом разделе lv_root файловую систему
sudo mkfs.xfs /dev/vg_root/lv_root

6. Смонтируем логический раздел lv_root в каталог /mnt
sudo mount /dev/vg_root/lv_root /mnt

7. Cкопируем все данные с раздела LogVol00 в раздел lv_root
(Примечание - копирование с указанием sudo не проходит, необходимо перейти в суперпользователя: sudo su)
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt

8. Проверим все ли скопировалось в раздел lv_root
ls /mnt

9. Смонтируем часть файловой структуры в другой каталог, не удаляя при этом исходную точку монтирования
(Примечание - необходимо перейти в суперпользователя: sudo su)
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

10. Сменим корневую директорию (/) на каталог /mnt
chroot /mnt/

