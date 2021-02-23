#!/bin/sh

echo "INFO: --- Gadget Subface RGB camera ---"

if [ $(id -u) -ne 0 ]
then
    echo "Please run as root"
    exit
fi

# Get configfs mountpoit
CONFIGFS_PATH=$(findmnt -t configfs -n --output=target)

if [ -e "${CONFIGFS_PATH}" ]; then
    echo "INFO: Configfs path: ${CONFIGFS_PATH}"
else
    echo "ERROR: Configfs path is not accessible"
    exit 1
fi

GADGET_PATH="${CONFIGFS_PATH}/usb_gadget/subface_gadget"

echo "INFO: Gadget config path: ${GADGET_PATH}"

mkdir "${GADGET_PATH}"

echo 0xEF   > "${GADGET_PATH}/bDeviceClass"
echo 0x02   > "${GADGET_PATH}/bDeviceSubClass"
echo 0x01   > "${GADGET_PATH}/bDeviceProtocol"

echo 0x1d6b > "${GADGET_PATH}/idVendor"
echo 0x0104 > "${GADGET_PATH}/idProduct"
echo 0x0100 > "${GADGET_PATH}/bcdDevice"
echo 0x0200 > "${GADGET_PATH}/bcdUSB"

mkdir "${GADGET_PATH}/strings/0x409"
echo "Subface"              > "${GADGET_PATH}/strings/0x409/manufacturer"
echo "Subface RGB Camera"   > "${GADGET_PATH}/strings/0x409/product"
echo 202102140001           > "${GADGET_PATH}/strings/0x409/serialnumber"

# Helper function for supported streaming formats
config_frame () {
    UVC=$1
    FORMAT=$2
    NAME=$3
	WIDTH=$4
	HEIGHT=$5
	
    FRAMEDIR=${UVC}/streaming/${FORMAT}/${NAME}/${WIDTH}x${HEIGHT}p

    mkdir -p ${FRAMEDIR}

    echo $WIDTH > ${FRAMEDIR}/wWidth
    echo $HEIGHT > ${FRAMEDIR}/wHeight
    echo 333333 > ${FRAMEDIR}/dwDefaultFrameInterval
    echo $((${WIDTH} * ${HEIGHT} * 80)) > ${FRAMEDIR}/dwMinBitRate
    echo $((${WIDTH} * ${HEIGHT} * 160)) > ${FRAMEDIR}/dwMaxBitRate
    echo $((${WIDTH} * ${HEIGHT} * 2)) > ${FRAMEDIR}/dwMaxVideoFrameBufferSize
    cat <<EOF > ${FRAMEDIR}/dwFrameInterval
333333
400000
666666
EOF
}

# UVC configuration
mkdir "${GADGET_PATH}/configs/c.1"
mkdir "${GADGET_PATH}/configs/c.1/strings/0x409"
echo 500 > "${GADGET_PATH}/configs/c.1/MaxPower"
echo "Subface Camera Front" > "${GADGET_PATH}/configs/c.1/strings/0x409/configuration"

# UVC functions (RGB)
FUNCTIONS_UVC_RGB="${GADGET_PATH}/functions/uvc.usb0"

mkdir "${FUNCTIONS_UVC_RGB}"

echo 2048 > "${FUNCTIONS_UVC_RGB}/streaming_maxpacket"

# YUVY (YUY2) configuration
config_frame ${FUNCTIONS_UVC_RGB} uncompressed u 640 480

echo "INFO: Initialize configs and functions"

# UVC RGB
mkdir    "${FUNCTIONS_UVC_RGB}/streaming/header/h"
mkdir -p "${FUNCTIONS_UVC_RGB}/control/header/h"
ln -s    "${FUNCTIONS_UVC_RGB}/control/header/h"         "${FUNCTIONS_UVC_RGB}/control/class/fs/h"
ln -s    "${FUNCTIONS_UVC_RGB}/streaming/uncompressed/u" "${FUNCTIONS_UVC_RGB}/streaming/header/h"
ln -s    "${FUNCTIONS_UVC_RGB}/streaming/header/h"       "${FUNCTIONS_UVC_RGB}/streaming/class/fs"
ln -s    "${FUNCTIONS_UVC_RGB}/streaming/header/h"       "${FUNCTIONS_UVC_RGB}/streaming/class/hs"
ln -s    "${FUNCTIONS_UVC_RGB}"                          "${GADGET_PATH}/configs/c.1/uvc.usb0"

echo "INFO: Enabling gadget"

udevadm settle -t 5 || :
ls /sys/class/udc > "${GADGET_PATH}/UDC"

echo "INFO: End"
