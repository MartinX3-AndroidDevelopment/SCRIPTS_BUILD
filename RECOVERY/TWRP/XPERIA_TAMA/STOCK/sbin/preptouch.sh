#!/sbin/sh
#
# Copyright (c) 2019 Martin Dünkelmann
# All rights reserved.
#
# We use this shell script because the script will follow symlinks and
# different trees will use different binaries to supply the setenforce
# tool. Before M we use toolbox, M and beyond will use toybox. The init
# binary and init.rc will not follow symlinks.

suffix=$(getprop ro.boot.slot_suffix)
if [[ -z "$suffix" ]]; then
	suf=$(getprop ro.boot.slot)
	suffix="_$suf"
fi

mkdir /v
mount -t ext4 -o ro "/dev/block/bootdevice/by-name/vendor$suffix" /v

touch_id=`cat /sys/devices/dsi_panel_driver/panel_id`

#XZ2 "3" XZ2C "4" Clearpad
if [[ "$touch_id" == "akari default" ]] || [[ "$touch_id" == "3" ]] || [[ "$touch_id" == "4" ]]; then
    cp /v/lib/modules/clearpad_rmi_dev.ko /sbin/
    cp /v/lib/modules/clearpad_core.ko /sbin/
    cp /v/lib/modules/clearpad_i2c.ko /sbin/

    insmod /sbin/clearpad_rmi_dev.ko
    insmod /sbin/clearpad_core.ko
    insmod /sbin/clearpad_i2c.ko
    echo 1 > /sys/devices/virtual/input/clearpad/post_probe_start
fi

#XZ2 "7" XZ2C "8" TCM
if [[ "$touch_id" == "apollo default" ]] || [[ "$touch_id" == "7" ]] || [[ "$touch_id" == "8" ]]; then
    cp /v/lib/modules/tof_sensor.ko /sbin/
    cp /v/lib/modules/tcs3490.ko /sbin/
    cp /v/lib/modules/sony_camera.ko /sbin/
    cp /v/lib/modules/fpc1075_platform.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_i2c.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_core.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_touch.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_device.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_testing.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_reflash.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_recovery.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_diagnostics.ko /sbin/

    insmod /sbin/tof_sensor.ko
    insmod /sbin/tcs3490.ko
    insmod /sbin/sony_camera.ko
    insmod /sbin/fpc1075_platform.ko
    insmod /sbin/synaptics_tcm_i2c.ko
    insmod /sbin/synaptics_tcm_core.ko
    insmod /sbin/synaptics_tcm_touch.ko
    insmod /sbin/synaptics_tcm_device.ko
    insmod /sbin/synaptics_tcm_testing.ko
    insmod /sbin/synaptics_tcm_reflash.ko
    insmod /sbin/synaptics_tcm_recovery.ko
    insmod /sbin/synaptics_tcm_diagnostics.ko
fi

#XZ2P SSW
if [[ "$touch_id" == "aurora default" ]] || [[ "$touch_id" == "9" ]]; then
    cp /v/lib/modules/ssw49501.ko /sbin/
    cp /v/lib/modules/ssw_mon.ko /sbin/

    insmod /sbin/ssw49501.ko
    insmod /sbin/ssw_mon.ko
    echo 1 > /sys/devices/virtual/input/siw_touch_input/init_late_session
fi

#XZ3 ATMEL
if [[ "$touch_id" == "akatsuki default" ]] || [[ "$touch_id" == "5" ]]; then
    cp /v/lib/modules/atmel_mxt640u.ko /sbin/

    insmod /sbin/atmel_mxt640u.ko
    echo 1 > /sys/devices/virtual/input/lge_touch/charge_out
fi

umount /v
rm -r /v
