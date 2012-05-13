#!/sbin/busybox sh

#ThunderBolt! & TweakLite

#Credits:
# Zacharias.maladroit
# Voku1987
# Collin_ph@xda
# Dorimanx@xda
# Gokhanmoral@xda

# TAKE NOTE THAT LINES PRECEDED BY A "#" IS COMMENTED OUT!

# ==============================================================
# I/O related tweaks 
# ==============================================================
DM=`ls -d /sys/block/dm*`;
LOOP=`ls -d /sys/block/loop*`;
MMC=`ls -d /sys/block/mmc*`;
ZRM=`ls -d /sys/block/zram*`;
RAM=`ls -d /sys/block/ram*`;

for i in $DM $LOOP $MMC $ZRM $RAM;
do
	if [ -e $i/queue/rotational ]; 
	then
		echo "0" > $i/queue/rotational;
	fi;

	if [ -e $i/queue/iostats ];
	then
		echo "0" > $i/queue/iostats;
	fi;

	if [ -e $i/queue/iosched/low_latency ];
	then
		echo "1" > $i/queue/iosched/low_latency;
	fi;

	if [ -e $i/queue/rq_affinity ];
	then
		echo "1" > $i/queue/rq_affinity;   
	fi;

	if [ -e $i/queue/read_ahead_kb ];
	then
		echo "512" >  $i/queue/read_ahead_kb;
	fi;

	#if [ -e $i/queue/iosched/group_isolation ];
	#then
	#	echo "0" > $i/queue/iosched/group_isolation;
	#fi;

	#if [ -e $i/queue/iosched/back_seek_penalty ];
	#then
	#	echo "1" > $i/queue/iosched/back_seek_penalty;
	#fi;

	#if [ -e $i/queue/iosched/writes_starved ];
	#then
	#	echo "1" > $i/queue/iosched/writes_starved;
	#fi;

	#if [ -e $i/queue/iosched/rev_penalty ];
	#then
	#	echo "1" > $i/queue/iosched/rev_penalty;
	#fi;

	#if [ -e $i/queue/iosched/slice_async_rq ];
	#then
	#	echo "2" > $i/queue/iosched/slice_async_rq;
	#fi;

	#if [ -e $i/queue/iosched/back_seek_max ];
	#then
	#	echo "1000000000" > $i/queue/iosched/back_seek_max;
	#fi;

	IO_SCHEDULER=`cat $i/queue/scheduler | sed 's/.*\[//g' | sed 's/\].*//g'`; 
	case $IO_SCHEDULER in
		"cfq")
			echo "0" > $i/queue/iosched/slice_idle;
    		echo "1024" > $i/queue/nr_requests;;
		"bfq")
			echo "3" > $i/queue/iosched/slice_idle;
		    echo "512" > $i/queue/nr_requests;;
		"noop")
		    echo "256" > $i/queue/nr_requests;;
		"deadline")
			echo "16" > $i/queue/iosched/fifo_batch;;
		"sio")
			echo "1" > $i/queue/iosched/fifo_batch;
			echo "256" > $i/queue/nr_requests;;
	esac;
done;

if [ -e /sys/devices/virtual/bdi/179:16/read_ahead_kb ];
then
	echo "1024" > /sys/devices/virtual/bdi/179:16/read_ahead_kb;
fi;

if [ -e /sys/devices/virtual/bdi/179:24/read_ahead_kb ];
then
	echo "1024" > /sys/devices/virtual/bdi/179:24/read_ahead_kb;
fi;

if [ -e /sys/devices/virtual/bdi/default/read_ahead_kb ];
then
	echo "512" > /sys/devices/virtual/bdi/default/read_ahead_kb;
fi;

# =========
# Remount all partitions
# =========
for k in $(busybox mount | grep relatime | cut -d " " -f3);
do
	busybox mount -o remount,rw,noatime,nodiratime $k;
done;

for l in $(busybox mount | grep ext[3-4] | cut -d " " -f3);
do
	mount -o remount,noatime,nodiratime,inode_readahead_blks=2,barrier=0,commit=30 $l;
done;

mount -o remount,rw,noatime,nodiratime,nodev,nobh,nouser_xattr,inode_readahead_blks=2,barrier=0,commit=180,noauto_da_alloc,delalloc /cache;
mount -o remount,rw,noatime,nodiratime,nodev,nobh,nouser_xattr,inode_readahead_blks=2,barrier=0,commit=30,noauto_da_alloc,delalloc /data;
mount -o remount,rw,noatime,nodiratime,inode_readahead_blks=2,barrier=0,commit=0 /system

# ==============================================================
# TWEAKS
# ==============================================================
echo "0" > /proc/sys/vm/oom_kill_allocating_task;
sysctl -w vm.panic_on_oom=0
sysctl -w kernel.tainted=0
sysctl -w kernel.sem="500 512000 100 2048";
sysctl -w kernel.shmmax="268435456";
echo "64000" > /proc/sys/kernel/msgmni;
echo "64000" > /proc/sys/kernel/msgmax;

# enable Hardware Rendering
setprop video.accelerate.hw 1
setprop debug.performance.tuning 1
setprop persist.sys.use_dithering 1

# render UI with GPU
setprop hwui.render_dirty_regions false
setprop windowsmgr.max_events_per_sec 120
setprop debug.sf.hw 1
setprop profiler.force_disable_err_rpt 1
setprop profiler.force_disable_ulog 1

# Proximity tweak
setprop mot.proximity.delay 15

# more Tweaks
setprop dalvik.vm.execution-mode int:jit
setprop persist.adb.notify 0
setprop hs.systemserver 16m
setprop hs.app.process 16m
setprop hs.su 8m
setprop hs.app_process 16m

# =========
# BATTERY-TWEAKS
# =========
setprop wifi.supplicant_scan_interval 240 
setprop pm.sleep_mode 1

for i in $(ls /sys/bus/usb/devices/*/power/level);
do
    echo "auto" > $i;
done;

# =========
# CPU-TWEAKS
# ========= 
# Frequency Scaling Governor
#echo "lulzactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
# MAX
#echo "1000000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
# MIN
#echo "100000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;

if [ -e /proc/sys/kernel/rr_interval ];
then
	# BFS;
	echo "1" > /proc/sys/kernel/rr_interval;
	echo "100" > /proc/sys/kernel/iso_cpu;
else
	# CFS;
	echo "10000000" > /proc/sys/kernel/sched_latency_ns;
	echo "2000000" > /proc/sys/kernel/sched_wakeup_granularity_ns;
	echo "4000000" > /proc/sys/kernel/sched_min_granularity_ns;
	echo "-1" > /proc/sys/kernel/sched_rt_runtime_us;
	echo "100000" > /proc/sys/kernel/sched_rt_period_us;
fi;

# 
# THX @mecss
# http://www.android-hilfe.de/kernel-fuer-samsung-galaxy-s2/214829-tweaks-kernel-parameter-einstellungen-governor-oc-uv.html
#
MORE_BATTERY=1;
MORE_SPEED=0;
KERNEL_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`;
if [ $KERNEL_GOVERNOR == "ondemand" ];
then
	if [ $MORE_BATTERY == 1 ];
	then
		echo "95" > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold;
		echo "120000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
		echo "1" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor;
		echo "5" > /sys/devices/system/cpu/cpufreq/ondemand/down_differential;
	else
		if [ $MORE_SPEED == 1 ];
		then
			echo "70" > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold;
			echo "60000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
			echo "2" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor;
			echo "15" > /sys/devices/system/cpu/cpufreq/ondemand/down_differential;
		fi;
	fi;
fi;
if [ $KERNEL_GOVERNOR == "lulzactive" ];
then
	if [ $MORE_BATTERY == 1 ];
	then
		echo "90" > /sys/devices/system/cpu/cpufreq/lulzactive/inc_cpu_load;
		echo "1" > /sys/devices/system/cpu/cpufreq/lulzactive/pump_up_step;
		echo "2" > /sys/devices/system/cpu/cpufreq/lulzactive/pump_down_step;
		echo "50000" > /sys/devices/system/cpu/cpufreq/lulzactive/up_sample_time;
		echo "40000" > /sys/devices/system/cpu/cpufreq/lulzactive/down_sample_time;
		echo "6" > /sys/devices/system/cpu/cpufreq/lulzactive/screen_off_min_step;
	else
		if [ $MORE_SPEED == 1 ];
		then
			echo "60" > /sys/devices/system/cpu/cpufreq/lulzactive/inc_cpu_load;
			echo "4" > /sys/devices/system/cpu/cpufreq/lulzactive/pump_up_step;
			echo "1" > /sys/devices/system/cpu/cpufreq/lulzactive/pump_down_step;
			echo "10000" > /sys/devices/system/cpu/cpufreq/lulzactive/up_sample_time;
			echo "70000" > /sys/devices/system/cpu/cpufreq/lulzactive/down_sample_time;
			echo "5" > /sys/devices/system/cpu/cpufreq/lulzactive/screen_off_min_step;
		fi;
	fi;
fi;
if [ $KERNEL_GOVERNOR == "smartassV2" ];
then
	if [ $MORE_BATTERY == 1 ];
	then
		echo "500000" > /sys/devices/system/cpu/cpufreq/smartass/awake_ideal_freq;
		echo "100000" > /sys/devices/system/cpu/cpufreq/smartass/sleep_ideal_freq;
		echo "500000" > /sys/devices/system/cpu/cpufreq/smartass/sleep_wakeup_freq
		echo "85" > /sys/devices/system/cpu/cpufreq/smartass/max_cpu_load;
		echo "70" > /sys/devices/system/cpu/cpufreq/smartass/min_cpu_load;
		echo "200000" > /sys/devices/system/cpu/cpufreq/smartass/ramp_up_step;
		echo "200000" > /sys/devices/system/cpu/cpufreq/smartass/ramp_down_step;
		echo "48000" > /sys/devices/system/cpu/cpufreq/smartass/up_rate_us
		echo "49000" > /sys/devices/system/cpu/cpufreq/smartass/down_rate_us
	else
		if [ $MORE_SPEED == 1 ];
		then
			echo "800000" > /sys/devices/system/cpu/cpufreq/smartass/awake_ideal_freq;
			echo "200000" > /sys/devices/system/cpu/cpufreq/smartass/sleep_ideal_freq;
			echo "800000" > /sys/devices/system/cpu/cpufreq/smartass/sleep_wakeup_freq
			echo "75" > /sys/devices/system/cpu/cpufreq/smartass/max_cpu_load;
			echo "45" > /sys/devices/system/cpu/cpufreq/smartass/min_cpu_load;
			echo "0" > /sys/devices/system/cpu/cpufreq/smartass/ramp_up_step;
			echo "0" > /sys/devices/system/cpu/cpufreq/smartass/ramp_down_step;
			echo "24000" > /sys/devices/system/cpu/cpufreq/smartass/up_rate_us;
			echo "99000" > /sys/devices/system/cpu/cpufreq/smartass/down_rate_us;
		fi;
	fi;
fi;
if [ $KERNEL_GOVERNOR == "conservative" ];
then
	if [ $MORE_BATTERY == 1 ];
	then
		echo "95" > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
		echo "120000" > /sys/devices/system/cpu/cpufreq/conservative/sampling_rate;
		echo "1" > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor;
		echo "40" > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
		echo "10" > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
	else
		if [ $MORE_SPEED == 1 ];
		then
			echo "60" > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
			echo "40000" > /sys/devices/system/cpu/cpufreq/conservative/sampling_rate;
			echo "5" > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor;
			echo "20" > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
			echo "25" > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
		fi;
	fi;
fi;

# =========
# MEMORY-TWEAKS
# =========
echo "40" > /proc/sys/vm/swappiness;
#echo "0" > /proc/sys/vm/dirty_expire_centisecs;
#echo "0" > /proc/sys/vm/dirty_writeback_centisecs;
#echo "60" > /proc/sys/vm/dirty_background_ratio;
#echo "95" > /proc/sys/vm/dirty_ratio;
echo "25" > /proc/sys/vm/vfs_cache_pressure;
echo "4" > /proc/sys/vm/min_free_order_shift;
echo "0" > /proc/sys/vm/overcommit_memory;
echo "96 96" > /proc/sys/vm/lowmem_reserve_ratio;
echo "1" > /proc/sys/vm/page-cluster;
echo "1000" > /proc/sys/vm/overcommit_ratio;
echo "4096" > /proc/sys/vm/min_free_kbytes
echo "3" > /proc/sys/vm/drop_caches;
echo "1" > /proc/sys/vm/drop_caches;

# Define the memory thresholds at which the above process classes will
# be killed. These numbers are in pages (4k) -> (1 MB * 1024) / 4 = 256
#FOREGROUND_APP_MEM=8192;
#VISIBLE_APP_MEM=10240;
#SECONDARY_SERVER_MEM=12288;
#BACKUP_APP_MEM=12288;
#HOME_APP_MEM=12288;
#HIDDEN_APP_MEM=14336;
#CONTENT_PROVIDER_MEM=16384;
#EMPTY_APP_MEM=20480;
#echo "$FOREGROUND_APP_MEM,$VISIBLE_APP_MEM,$SECONDARY_SERVER_MEM,$HIDDEN_APP_MEM,$CONTENT_PROVIDER_MEM,$EMPTY_APP_MEM" > /sys/module/lowmemorykiller/parameters/minfree;

# =========
# FS-TWEAKS
# =========
echo "15" > /proc/sys/fs/lease-break-time;

# =========
# TWEAKS: for TCP read/write
# =========
echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
echo "1" > /proc/sys/net/ipv4/tcp_sack;
echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf;
echo "1" > /proc/sys/net/ipv4/route/flush;
echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes;
echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl;
echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout;
echo "404480" > /proc/sys/net/core/wmem_max;
echo "404480" > /proc/sys/net/core/rmem_max;
echo "256960" > /proc/sys/net/core/rmem_default;
echo "256960" > /proc/sys/net/core/wmem_default;
echo "20480" > /proc/sys/net/core/optmem_max;
echo "4096 16384 404480" > /proc/sys/net/ipv4/tcp_wmem;
echo "4096 87380 404480" > /proc/sys/net/ipv4/tcp_rmem;
echo "4096" > /proc/sys/net/ipv4/udp_rmem_min;
echo "4096" > /proc/sys/net/ipv4/udp_wmem_min;
setprop net.tcp.buffersize.default 4096,87380,704512,4096,16384,110208;
setprop net.tcp.buffersize.wifi	   4095,87380,256960,4096,16384,256960;
setprop net.tcp.buffersize.umts    4094,87380,563200,4096,16384,110208;
setprop net.tcp.buffersize.edge    4093,26280,35040,4096,16384,35040;
setprop net.tcp.buffersize.gprs    4092,8760,11680,4096,8760,11680;
setprop net.tcp.buffersize.evdo_b  4094,87380,262144,4096,16384,262144;
setprop net.tcp.buffersize.hspa    4092,87380,704512,4096,16384,110208;

# =========
# TWEAKS: optimized for 3G/Edge speed
# =========
setprop ro.ril.hsxpa 2;
setprop ro.ril.hsupa.category 14;
setprop ro.ril.hsdpa.category 6;
setprop ro.ril.gprsclass 12;

# =========
# Firewall-TWEAKS
# =========
# ping/icmp protection
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts;
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all;
echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses;

if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts ];
then
	echo "1" > /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts;
fi;

if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_all ];
then
	echo "1" > /proc/sys/net/ipv6/icmp_echo_ignore_all;
fi;

if [ -e /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses ];
then
	echo "1" > /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses;
fi;

# syn protection
echo "2" > /proc/sys/net/ipv4/tcp_synack_retries;

if [ -e /proc/sys/net/ipv6/tcp_synack_retries ];
then
	echo "2" > /proc/sys/net/ipv6/tcp_synack_retries;
fi;

if [ -e /proc/sys/net/ipv6/tcp_syncookies ];
then
	echo "0" > /proc/sys/net/ipv6/tcp_syncookies;
fi;

if [ -e /proc/sys/net/ipv4/tcp_syncookies ];
then
	echo "1" > /proc/sys/net/ipv4/tcp_syncookies;
fi;

# IPv6 privacy tweak
echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr;

# drop spoof, redirects, etc
echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter;
echo "1" > /proc/sys/net/ipv4/conf/default/rp_filter;
echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects;
echo "0" > /proc/sys/net/ipv4/conf/default/send_redirects;
echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects;
echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route;
echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route;

if [ -e /proc/sys/net/ipv6/conf/all/rp_filter ];
then
	echo "1" > /proc/sys/net/ipv6/conf/all/rp_filter;
fi;

if [ -e /proc/sys/net/ipv6/conf/default/rp_filter ];
then
	echo "1" > /proc/sys/net/ipv6/conf/default/rp_filter;
fi;

if [ -e /proc/sys/net/ipv6/conf/all/send_redirects ];
then
	echo "0" > /proc/sys/net/ipv6/conf/all/send_redirects;
fi;

if [ -e /proc/sys/net/ipv6/conf/default/send_redirects ];
then
	echo "0" > /proc/sys/net/ipv6/conf/default/send_redirects;
fi;

if [ -e /proc/sys/net/ipv6/conf/default/accept_redirects ];
then
	echo "0" > /proc/sys/net/ipv6/conf/default/accept_redirects;
fi;

if [ -e /proc/sys/net/ipv6/conf/all/accept_source_route ];
then
	echo "0" > /proc/sys/net/ipv6/conf/all/accept_source_route;
fi;

if [ -e /proc/sys/net/ipv6/conf/default/accept_source_route ];
then
	echo "0" > /proc/sys/net/ipv6/conf/default/accept_source_route;
fi;

# =========
# Renice - kernel thread responsible for managing the memory
# =========
renice 19 `pidof kswapd0`;

# ==============================================================
# Explanations
# ==============================================================
#
# scaling_governor: Using Frequency Scaling Governors -> cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
#
# 				-> http://publib.boulder.ibm.com/infocenter/lnxinfo/v3r0m0/index.jsp?topic=/liaai/cpufreq/TheOndemandGovernor.htm
#
# 				conservative - Increases frequency step by step, decreases instantly
# 				ondemand - Uses the highest CPU frequency when tasks are started, decreases step by step
# 				performance - CPU only runs at max frequency regardless of load
# 				powersave - CPU only runs at min frequency regardless of load
#
# 				echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# swappiness: 	swappiness is a parameter which sets the kernel's balance between reclaiming pages from the page cache and swapping process memory. 
#				The default value is 60. If you want kernel to swap out more process memory and thus cache more file contents increase the value. 
#				Otherwise, if you would like kernel to swap less decrease it. A value of 0 means "do not swap unless out of free RAM", 
#				a value of 100 means "swap whenever possible". 
#
# 				echo XXX > /proc/sys/vm/swappiness;

# oom_kill_allocating_task:	If this is set to zero, the OOM killer will scan through the entire tasklist and select a task based on heuristics to kill. 
#				This normally selects a rogue memory-hogging task that frees up a large amount of memory when killed. 
#				If this is set to non-zero, the OOM killer simply kills the task that triggered the out-of-memory condition. 
#				This avoids the expensive tasklist scan.
#
# 				echo XXX > /proc/sys/vm/oom_kill_allocating_task;

# dirty_expire_centisecs: This tunable is used to define when dirty data is old enough to be eligible for writeout by the pdflush daemons. 
#				It is expressed in 100'ths of a second. Data which has been dirty in memory for longer than this interval will be written 
#				out next time a pdflush daemon wakes up.
#
# 				echo XXX > /proc/sys/vm/dirty_expire_centisecs;

# dirty_writeback_centisecs: The pdflush writeback daemons will periodically wake up and write "old" data out to disk. 
#				This tunable expresses the interval between those wakeups, in 100'ths of a second. 
#				Setting this to zero disables periodic writeback altogether.
#
# 				echo XXX > /proc/sys/vm/dirty_writeback_centisecs;

# drop_caches:	Writing to this will cause the kernel to drop clean caches, dentries and inodes from memory, causing that memory to become free.
#
#				To free pagecache:
# 				echo 1 > /proc/sys/vm/drop_caches
#
#				To free dentries and inodes:
# 				echo 2 > /proc/sys/vm/drop_caches
#
#				To free pagecache, dentries and inodes:
# 				echo 3 > /proc/sys/vm/drop_caches

# page-cluster: page-cluster controls the number of pages which are written to swap in a single attempt. The swap I/O size.
#				It is a logarithmic value - setting it to zero means "1 page", setting it to 1 means "2 pages", setting it to 2 means "4 pages", etc.
#				The default value is three (eight pages at a time). There may be some small benefits in tuning this to 
#				a different value if your workload is swap-intensive. (default 3)
#
# 				echo XXX > /proc/sys/vm/page-cluster;

# laptop_mode: 	laptop_mode is a knob that controls "laptop mode". When the knob is set, any physical disk I/O 
#				(that might have caused the hard disk to spin up, see /proc/sys/vm/block_dump) causes Linux to flush all dirty blocks. 
#				The result of this is that after a disk has spun down, it will not be spun up anymore to write dirty blocks, 
#				because those blocks had already been written immediately after the most recent read operation. 
#				The value of the laptop_mode knob determines the time between the occurrence of disk I/O and when the flush is triggered. 
#				A sensible value for the knob is 5 seconds. Setting the knob to 0 disables laptop mode.
#
# 				echo XXX > /proc/sys/vm/laptop_mode;

# rr_interval: 	rr_interval or "round robin interval". This is the maximum time two SCHED_OTHER (or SCHED_NORMAL, the common scheduling policy)
#				tasks of the same nice level will be running for, or looking at it the other way around, the longest duration two tasks 
#				of the same nice level will be delayed for. When a task requests cpu time, it is given a quota (time_slice) equal to the 
#				rr_interval and a virtual deadline, while increasing it will improve throughput, but at the cost of worsening latencies.
#
# 				echo XXX > /proc/sys/kernel/rr_interval;

# dirty_background_ratio: 	Contains, as a percentage of total system memory, the number of pages at which the pdflush background writeback daemon will 
#				start writing out dirty data.
#
# 				echo XXX > /proc/sys/vm/dirty_background_ratio;

# dirty_ratio:	Contains, as a percentage of total system memory, the number of pages at which a process which is generating disk writes will 
#				itself start writing out dirty data.
#
# 				echo XXX > /proc/sys/vm/dirty_ratio;

# iso_cpu:		Setting this to 100 is the equivalent of giving all users SCHED_RR access and setting it to 0 removes the
#				ability to run any pseudo-realtime tasks.
#
# 				echo XXX > /proc/sys/kernel/iso_cpu;

# vfs_cache_pressure: Controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects.
#				At the default value of vfs_cache_pressure = 100 the kernel will attempt to reclaim dentries and inodes at a "fair" rate with respect 
#				to pagecache and swapcache reclaim. Decreasing vfs_cache_pressure causes the kernel to prefer to retain dentry and inode caches. 
#				Increasing vfs_cache_pressure beyond 100 causes the kernel to prefer to reclaim dentries and inodes.
#
# 				echo XXX > /proc/sys/vm/vfs_cache_pressure;

# min_free_kbytes: This is used to force the Linux VM to keep a minimum number of kilobytes free. The VM uses this number to compute a pages_min value 
#				for each lowmem zone in the system. Each lowmem zone gets a number of reserved free pages based proportionally on its size.
#
# 				echo XXX > /proc/sys/vm/min_free_kbytes;

# sched_latency_ns: Targeted preemption latency for CPU-bound tasks.
#
# 				echo XXX > /proc/sys/kernel/sched_latency_ns;

# sched_batch_wakeup_granularity_ns: Wake-up granularity for SCHED_BATCH.
#
# 				echo XXX > /proc/sys/kernel/sched_batch_wakeup_granularity_ns;

# sched_wakeup_granularity_ns: 	Wake-up granularity for SCHED_OTHER.
#
# 				echo XXX > /proc/sys/kernel/sched_wakeup_granularity_ns;

# sched_compat_yield: 		Applications depending heavily on sched_yield()'s behavior can expect varied performance because of the way CFS changes this, 
#				so turning on the sysctls is recommended.
#
# 				echo XXX > /proc/sys/kernel/sched_compat_yield;

# sched_child_runs_first: 	The child is scheduled next after fork; it's the default. If set to 0, then the parent is given the baton.
#
# 				echo XXX > /proc/sys/kernel/sched_child_runs_first;

# sched_min_granularity_ns:	Minimum preemption granularity for CPU-bound tasks.
#
# 				echo XXX > /proc/sys/kernel/sched_min_granularity_ns;

# sched_features: NO_NEW_FAIR_SLEEPERS is something that will turn the scheduler into a more classic fair scheduler ?!?
#
# 				echo NO_NORMALIZED_SLEEPER > /sys/kernel/debug/sched_features;

# sched_stat_granularity_ns: Granularity for collecting scheduler statistics. [1/0]
#
# 				echo XXX  > /proc/sys/kernel/sched_stat_granularity_ns;

# sched_rt_period_us: The default values for sched_rt_period_us (1000000 or 1s) and sched_rt_runtime_us (950000 or 0.95s).  
#				This gives 0.05s to be used by SCHED_OTHER (non-RT tasks). These defaults were chosen so that a run-away realtime 
#				tasks will not lock up the machine but leave a little time to recover it. By setting runtime to -1 you get the old behaviour back.

# threads-max: Gets/sets the limit on the maximum number of running threads system-wide.
#
# 				echo XXX > /proc/sys/kernel/threads-max;

# msgmni: 		The msgmni tunable specifies the maximum number of system-wide System V IPC message queue 
#				identifiers (one per queue).
#
# 				echo XXX > /proc/sys/kernel/msgmni;

# sem: 			This file contains 4 numbers defining limits for System V IPC semaphores. These fields are, in order:
#
# 				SEMMSL - the maximum number of semaphores per semaphore set.
# 				SEMMNS - a system-wide limit on the number of semaphores in all semaphore sets.
# 				SEMOPM - the maximum number of operations that may be specified in a semop(2) call.
# 				SEMMNI - a system-wide limit on the maximum number of semaphore identifiers.
#
# 				The default values are "250 32000 32 128".
#
# 				echo XXX XXX XXX XXX > /proc/sys/kernel/sem;

# read_ahead_kb: Optimize for read-throughput (cache-value)
#
# 				example of C program for finding correct vaules for Linux 
# 				-> http://pastebin.com/Rg6qVJQH
#
