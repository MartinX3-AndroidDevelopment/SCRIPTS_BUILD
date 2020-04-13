#!/sbin/sh
#
# Copyright (c) 2019-2020 Martin Dünkelmann
# All rights reserved.
#
# We use this shell script because the script will follow symlinks and
# different trees will use different binaries to supply the setenforce
# tool. Before M we use toolbox, M and beyond will use toybox. The init
# binary and init.rc will not follow symlinks.

#Suffix for A/B devices is either _a or _b depending on which slot is active
suffix=$(getprop ro.boot.slot_suffix)

mkdir /v
mount -t ext4 -o ro "/dev/block/bootdevice/by-name/vendor$suffix" /v

touch_id=`cat /sys/devices/dsi_panel_driver/panel_id`

#XZ2 "3" XZ2C "4" Clearpad
if [[ "$touch_id" == "3" ]] || [[ "$touch_id" == "4" ]]; then
    cp /v/lib/modules/clearpad_rmi_dev.ko /sbin/
    cp /v/lib/modules/clearpad_core.ko /sbin/
    cp /v/lib/modules/clearpad_i2c.ko /sbin/

    chmod +x /sbin/clearpad_rmi_dev.ko
    chmod +x /sbin/clearpad_core.ko
    chmod +x /sbin/clearpad_i2c.ko

    insmod /sbin/clearpad_rmi_dev.ko
    insmod /sbin/clearpad_core.ko
    insmod /sbin/clearpad_i2c.ko

    echo 1 > /sys/devices/virtual/input/clearpad/post_probe_start
fi

#XZ2 "7" XZ2C "8" TCM
if [[ "$touch_id" == "7" ]] || [[ "$touch_id" == "8" ]]; then
    cp /v/lib/modules/synaptics_tcm_i2c.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_core.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_touch.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_device.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_testing.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_reflash.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_recovery.ko /sbin/
    cp /v/lib/modules/synaptics_tcm_diagnostics.ko /sbin/

    chmod +x /sbin/synaptics_tcm_i2c.ko
    chmod +x /sbin/synaptics_tcm_core.ko
    chmod +x /sbin/synaptics_tcm_touch.ko
    chmod +x /sbin/synaptics_tcm_device.ko
    chmod +x /sbin/synaptics_tcm_testing.ko
    chmod +x /sbin/synaptics_tcm_reflash.ko
    chmod +x /sbin/synaptics_tcm_recovery.ko
    chmod +x /sbin/synaptics_tcm_diagnostics.ko

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
if [[ "$touch_id" == "9" ]]; then
    cp /v/lib/modules/ssw49501.ko /sbin/
    cp /v/lib/modules/ssw_mon.ko /sbin/

    chmod +x /sbin/ssw49501.ko
    chmod +x /sbin/ssw_mon.ko

    insmod /sbin/ssw49501.ko
    insmod /sbin/ssw_mon.ko

    echo 1 > /sys/devices/virtual/input/siw_touch_input/init_late_session
fi

#XZ3 ATMEL
if [[ "$touch_id" == "akatsuki default" ]] || [[ "$touch_id" == "5" ]]; then
    cp /v/lib/modules/atmel_mxt640u.ko /sbin/

    chmod +x /sbin/atmel_mxt640u.ko

    insmod /sbin/atmel_mxt640u.ko

    echo 1 > /sys/devices/virtual/input/lge_touch/charge_out
fi

umount /v
rm -r /v
