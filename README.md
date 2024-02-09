# veritymobile

Security Framework for Mobile Linux

veritymobile aims to bring easy to use Secure Boot and Measured Boot to the PinePhone Pro with hardware-backed security and fully open source code.

At the moment this project is *highly experimental* and should not be considered secure.

Checkout `dev-wip` branch for more...

Current state:

- Secure payload is delivered with mainline u-boot v2023.10
- OP-TEE mostly works on PinePhone Pro, but not validated to be secure
- Runtime access to fTPM is possible, manual intervention requried

Tasks:

- Validate platform and possibly upstream PinePhonePro support for OPTEE
- Investigate possible hardware root-of-trust (RK3399's BootROM supports verified boot, but does it work? how?)
- Use RPMB area in the eMMC for OPTEE secure storage

Quickstart:

Default user name: `mobian`
Default password: `1234`
