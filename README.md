# veritymobile

Security Framework for Mobile Linux

veritymobile aims to bring easy to use Secure Boot and Measured Boot to the PinePhone Pro with hardware-backed security and fully open source code.

At this stage this project is *highly experimental* and should not be considered secure. A prebuilt Mobian image for the PinePhone Pro is available for testing.


### Internals

The PinePhone Pro is based on Rockchip's RK3399 SoC, which comes with support for ARM's TrustZone feature. TrustZone allows for hardware-enforced isolation which when coupled with [OP-TEE][1] and [fTPM][2], can provide a TPM (Trusted Platform Module) for sensitive operations to be securely delegated to. In a secure setup, operations in the TrustZone will not be affected from compromise of the primary Linux system.

Since OP-TEE and fTPM is initialized before the Linux kernel, U-Boot the bootloader can measure the payloads (kernel, dtb, initramfs...) before continuing with the boot process, and the measurements can then be used to unseal key materials or be used by user space applications.

A general PKCS#11 interface backed by the TPM is available for user space applications to delegate crypto operations. (OP-TEE also provides a [native PKCS#11 interface][4], bypassing the TPM)

----------

Warning: `optee_os` built by this repository is configured with `CFG_RPMB_WRITE_KEY=y`, it will burn the testkey into the RPMB section of your PinePhone Pro's emmc controller when executed in order to provide secure storage before local Linux file system is ready, this is not reversible and you might want to use different configuration for your setup.

see `commit 89e96a6cfa68436b4001b617806666f6d78e9899` and [optee's docs][3] for more.

Current state:

- Secure payload is delivered with mainline u-boot v2024.01
- OP-TEE mostly works on PinePhone Pro, but not validated to be secure
- Runtime access to fTPM is possible, manual intervention requried
- RPMB is used for persistent secure storage for optee os

Tasks:

- Validate platform and possibly upstream PinePhonePro support for OPTEE
- Investigate possible hardware root-of-trust (RK3399's BootROM supports verified boot, but does it work? how?)

Quickstart:

Default user name: `mobian`
Default password: `1234`

[1]: https://optee.readthedocs.io/en/latest/general/about.html
[2]: https://github.com/microsoft/MSRSec
[3]: https://optee.readthedocs.io/en/latest/architecture/secure_storage.html#rpmb-secure-storage
[4]: https://optee.readthedocs.io/en/latest/building/userland_integration.html
