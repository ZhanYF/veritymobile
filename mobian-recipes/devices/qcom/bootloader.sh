#!/bin/sh

SCRIPT="$0"
DEVICE="$1"

CONFIG="$(dirname ${SCRIPT})/configs/${DEVICE}.toml"
if ! [ -f "${CONFIG}" ]; then
    echo "ERROR: No configuration for device type '${DEVICE}'!"
    exit 1
fi

ROOTPART="UUID=$(findmnt -n -o UUID /)"
if [ "${ROOTPART}" = "UUID=" ]; then
    # This means we're using an encrypted rootfs
    ROOTPART="/dev/mapper/root"
fi
KERNEL_VERSION=$(linux-version list)

# Parse config for generic parameters for the current SoC
SOC=$(tomlq -r "if .chipset then .chipset else \"${DEVICE}\" end" ${CONFIG})
KERNEL_ADDR="$(tomlq -r '.bootimg.kernel + .bootimg.base' ${CONFIG})"
RAMDISK_ADDR="$(tomlq -r '.bootimg.ramdisk + .bootimg.base' ${CONFIG})"
SECOND_ADDR="$(tomlq -r '.bootimg.second + .bootimg.base' ${CONFIG})"
TAGS_ADDR="$(tomlq -r '.bootimg.tags + .bootimg.base' ${CONFIG})"
PAGE_SIZE="$(tomlq -r '.bootimg.pagesize' ${CONFIG})"

for i in $(seq 0 $(tomlq -r '.device | length - 1' ${CONFIG})); do
    # Parse device-specific parameters
    VENDOR=$(tomlq -r ".device[$i].vendor" ${CONFIG})
    MODEL=$(tomlq -r ".device[$i].model" ${CONFIG})
    VARIANT=$(tomlq -r "if .device[$i].variant then .device[$i].variant else \"\" end" ${CONFIG})
    DEVICE_SOC=$(tomlq -r "if .device[$i].chipset then .device[$i].chipset else \"${SOC}\" end" ${CONFIG})
    APPEND=$(tomlq -r "if .device[$i].append then .device[$i].append else \"\" end" ${CONFIG})

    CMDLINE="mobile.qcomsoc=qcom/${DEVICE_SOC} mobile.vendor=${VENDOR} mobile.model=${MODEL}"
    if [ "${VARIANT}" ]; then
        CMDLINE="${CMDLINE} mobile.variant=${VARIANT}"
        FULLMODEL="${MODEL}-${VARIANT}"
    else
        FULLMODEL="${MODEL}"
    fi
    DTB_FILE="/usr/lib/linux-image-${KERNEL_VERSION}/qcom/${DEVICE_SOC}-${VENDOR}-${FULLMODEL}.dtb"

    # Include additional cmdline args if specified
    if [ "${APPEND}" ]; then
        CMDLINE="${CMDLINE} ${APPEND}"
    fi

    # Append DTB to kernel
    echo "Creating boot image for ${FULLMODEL}..."
    cat /boot/vmlinuz-${KERNEL_VERSION} ${DTB_FILE} > /tmp/kernel-dtb

    # Create the bootimg as it's the only format recognized by the Android bootloader
    abootimg --create /bootimg-${FULLMODEL} \
        -c kerneladdr=${KERNEL_ADDR} -c ramdiskaddr=${RAMDISK_ADDR} \
        -c secondaddr=${SECOND_ADDR} -c tagsaddr=${TAGS_ADDR} -c pagesize=${PAGE_SIZE} \
        -c cmdline="mobile.root=${ROOTPART} ${CMDLINE} init=/sbin/init ro quiet splash" \
        -k /tmp/kernel-dtb -r /boot/initrd.img-${KERNEL_VERSION}
done
