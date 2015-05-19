#!/system/bin/sh

# Create an appropriate mdnie directory or fix permissions on existing
mkdir /data/mdnie
chown 0:0 /data/mdnie
chown -R 0:0 /data/mdnie
chmod 777 /data/mdnie
chmod -R 777 /data/mdnie

#mount -o remount,rw /
mount -o remount,rw /system /system


#echo "Fast Random Generator (frandom) support on boot"
#if [ -c "/dev/frandom" ]; then
#	# Redirect random and urandom generation to frandom char device
#	chmod 0666 /dev/frandom
#	chmod 0666 /dev/erandom
#	mv /dev/random /dev/random.ori
#	mv /dev/urandom /dev/urandom.ori
#	rm -f /dev/random
#	rm -f /dev/urandom
#	ln /dev/frandom /dev/random
#	chmod 0666 /dev/random
#	ln /dev/frandom /dev/urandom
#	chmod 0666 /dev/urandom
#fi

echo "Starting Haveged"
mv /dev/random /dev/random.ori
rm -f /dev/random
ln /dev/urandom /dev/random
chmod 0666 /dev/random
#nice -n +20 /sbin/haveged -s /dev/urandom.ori

echo "Init.d"
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/;
	chown -R root.root /system/etc/init.d;
	chmod 777 /system/etc/init.d/;
fi;

/system/xbin/run-parts /system/etc/init.d

echo "sysfs values"
echo 0 > /proc/sys/vm/oom_dump_tasks

#echo 1 > /proc/sys/vm/dynamic_dirty_writeback
echo 2000 > /proc/sys/vm/dirty_expire_centisecs
echo 3000 > /proc/sys/vm/dirty_writeback_centisecs
#echo 3000 > /proc/sys/vm/dirty_writeback_suspend_centisecs
#echo 12000 > /proc/sys/vm/dirty_writeback_active_centisecs

#echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

echo 2 > /sys/block/mmcblk0/queue/rq_affinity
echo 2 > /sys/block/mmcblk1/queue/rq_affinity
echo 0 > /sys/block/mmcblk0/queue/iostats
echo 0 > /sys/block/mmcblk1/queue/iostats
echo 0 > /sys/block/mmcblk0/queue/add_random
echo 0 > /sys/block/mmcblk1/queue/add_random
echo 0 > /sys/block/mmcblk0/queue/nomerges
echo 0 > /sys/block/mmcblk1/queue/nomerges

#echo 0 > /sys/kernel/dyn_fsync/Dyn_fsync_active
echo 0 > /proc/sys/vm/swappiness

mount -o remount,ro /
mount -o remount,ro /system /system

echo "more sysfs values"

echo "fiops" > /sys/block/mmcblk0/queue/scheduler
echo "fiops" > /sys/block/mmcblk1/queue/scheduler

echo "Trim"
/system/xbin/fstrim -v /system
/system/xbin/fstrim -v /data
/system/xbin/fstrim -v /cache
