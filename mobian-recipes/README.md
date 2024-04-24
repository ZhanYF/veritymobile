# mobian-recipes

A set of [debos](https://github.com/go-debos/debos) recipes for building a
debian-based image for mobile phones, initially targetting Pine64's PinePhone.

Prebuilt images are available [here](http://images.mobian.org/).

The default user is `mobian` with password `1234`.

## Build

To build the image, you need to have `debos` and `bmaptool`. On a Debian-based
system, install these dependencies by typing the following command in a terminal:

```
sudo apt install debos bmap-tools xz-utils
```

If you want to build an image for a Qualcomm-based device, additional packages
are required, which you can install with the following command:

```
sudo apt install android-sdk-libsparse-utils yq
```

Do note that we recommend using Debian 12 (Bookworm) as previous versions didn't
include the `yq` package.

Similarly, if you want to use F2FS for the root filesystem (which isn't such a
good idea, as it has been known to cause corruption in the past), you'll need to
install `f2fs-tools` as well.

The build system will cache and re-use it's output files. To create a fresh build
remove `*.tar.gz`, `*.sqfs` and `*.img` before starting the build.

If your system isn't debian-based (or if you choose to install `debos` without
using `apt`, which is a terrible idea), please make sure you also install the
following required packages:
- `debootstrap`
- `qemu-system-x86`
- `qemu-user-static`
- `binfmt-support`
- `squashfs-tools-ng` (only required for generating installer images)

Then simply browse to the `mobian-recipes` folder and execute `./build.sh`.

You can use `./build.sh -d` to use the docker version of `debos`.

### Building QEMU image

You can build a QEMU x86_64 image by adding the `-t amd64` flag to `build.sh`

The resulting files are raw images. You can start qemu like so:

```
qemu-system-x86_64 -drive format=raw,file=<imagefile.img> -enable-kvm \
    -cpu host -vga virtio -m 2048 -smp cores=4 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd
```

UEFI firmware files are available in Debian thanks to the
[OVMF](https://packages.debian.org/sid/all/ovmf/filelist) package.
Comprehensive explanation about firmware files can be found at
[OVMF project's repository](https://github.com/tianocore/edk2/tree/master/OvmfPkg).

You may also want to convert the raw image to qcow2 format
and resize it like this:

```
qemu-img convert -f raw -O qcow2 <raw_image.img> <qcow_image.qcow2>
qemu-img resize -f qcow2 <qcow_image.qcow2> +20G
```

## Install

Insert a MicroSD card into your computer, and type the following command:

```
sudo bmaptool copy <image> /dev/<sdcard>
```

or:

```
sudo dd if=<image> of=/dev/<sdcard> bs=1M
```

*Note: Make sure to use your actual SD card device, such as `mmcblk0` instead of
`<sdcard>`.*

**CAUTION: This will format the SD card and erase all its contents!!!**

## Contributing

If you want to help with this project, please have a look at the
[roadmap](https://wiki.debian.org/Teams/Mobian/Roadmap) and
[open issues](https://salsa.debian.org/Mobian-team/mobian-recipes/-/issues).

In case you need more information, feel free to get in touch with the developers
on [#mobian:matrix.org](https://matrix.to/#/#mobian:matrix.org).

# License

This software is licensed under the terms of the GNU General Public License,
version 3.
