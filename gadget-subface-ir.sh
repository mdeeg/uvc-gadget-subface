#!/bin/sh

echo "INFO: --- Gadget Subface IR camera ---"

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
echo "Subface"          > "${GADGET_PATH}/strings/0x409/manufacturer"
echo "Subface IR"       > "${GADGET_PATH}/strings/0x409/product"
echo 202102140001       > "${GADGET_PATH}/strings/0x409/serialnumber"

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
EOF
}

# UVC configuration
mkdir "${GADGET_PATH}/configs/c.1"
mkdir "${GADGET_PATH}/configs/c.1/strings/0x409"
echo 500 > "${GADGET_PATH}/configs/c.1/MaxPower"
echo "Subface IR Camera" > "${GADGET_PATH}/configs/c.1/strings/0x409/configuration"

# UVC functions (IR)
FUNCTIONS_UVC_IR="${GADGET_PATH}/functions/uvc.usb0"

mkdir "${FUNCTIONS_UVC_IR}"

echo 2048 > "${FUNCTIONS_UVC_IR}/streaming_maxpacket"

# L8 (8-bit greyscale format) configuration
config_frame ${FUNCTIONS_UVC_IR} uncompressed u 480 480

# Set pixel format to UVC_GUID_FORMAT_KSMEDIA_L8_IR
cat UVC_GUID_FORMAT_KSMEDIA_L8_IR > ${FUNCTIONS_UVC_IR}/streaming/uncompressed/u/guidFormat

# Set 8 bits per pixel
echo 8 > ${FUNCTIONS_UVC_IR}/streaming/uncompressed/u/bBitsPerPixel

echo "INFO: Initialize configs and functions"

# UVC IR
mkdir    "${FUNCTIONS_UVC_IR}/streaming/header/h"
mkdir -p "${FUNCTIONS_UVC_IR}/control/header/h"
ln -s    "${FUNCTIONS_UVC_IR}/control/header/h"         "${FUNCTIONS_UVC_IR}/control/class/fs/h"
ln -s    "${FUNCTIONS_UVC_IR}/streaming/uncompressed/u" "${FUNCTIONS_UVC_IR}/streaming/header/h"
ln -s    "${FUNCTIONS_UVC_IR}/streaming/header/h"       "${FUNCTIONS_UVC_IR}/streaming/class/fs"
ln -s    "${FUNCTIONS_UVC_IR}/streaming/header/h"       "${FUNCTIONS_UVC_IR}/streaming/class/hs"
ln -s    "${FUNCTIONS_UVC_IR}"                          "${GADGET_PATH}/configs/c.1/uvc.usb0"

echo "INFO: Enabling gadget"

udevadm settle -t 5 || :
ls /sys/class/udc > "${GADGET_PATH}/UDC"

echo "INFO: End"
