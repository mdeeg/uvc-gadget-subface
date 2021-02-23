# Subface Camera (Experimental UVC Gadget)

Subface Camera is an experimental UVC gadget based on the following uvc-gadget versions:

- Original [uvc-gadget.git](http://git.ideasonboard.org/uvc-gadget.git)
- Fork(copy) [uvc-gadget.git - wlhe](https://github.com/wlhe/uvc-gadget)
- Fork(copy) [uvc-gadget.git - climberhunt / Dave Hunt](https://github.com/climberhunt/uvc-gadget)
- Fork(copy) [uvc-gadget.git - peterbay / Petr Vavrin](https://github.com/peterbay/uvc-gadget)

# Hardware Requirements

* Raspberry Pi or similar device with USB device controller (UDC)


# Installation

```
git clone https://github.com/mdeeg/uvc-gadget-subface
cd uvc-gadget-subface
make
```

# Usage

First, the USB gadget has to be configured via configfs, for example using one of the provided shell scripts.

```
sudo sh ./gadget-subface-rgb.sh
```

Then, the UVC gadget can be started with suitable parameters, for example

```
./uvc-gadget -i images/hello_robot_640x480.png -u /dev/video0
```