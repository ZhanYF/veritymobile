# veritymobile

Security Framework for Mobile Linux

veritymobile aims to bring easy to use Secure Boot and Measured Boot to the PinePhone Pro with hardware-backed security and fully open source code.

At the moment this project is *highly experimental* and should not be considered secure.

Warning: `optee_os` built by this repository is configured with `CFG_RPMB_WRITE_KEY=y`, it will burn the testkey into the RPMB section of your PinePhone Pro's emmc controller when executed in order to provide secure storage before local Linux file system is ready, this is not reversible and you might want to use different configuration for your setup.

see `commit 89e96a6cfa68436b4001b617806666f6d78e9899` and [optee's docs][1] for more.

Checkout `dev-wip` branch for more...

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

[1]: https://optee.readthedocs.io/en/latest/architecture/secure_storage.html#rpmb-secure-storage
