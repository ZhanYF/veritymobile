################################################################################
# Targets
################################################################################

PROJECT_ROOT = $(shell pwd)

# all: arm_tfa optee_os ftpm optee_os_with_earlyTA u-boot mobian_image
#all: arm-tfa



.PHONY: init
init:
	cd external/MSRSec && git submodule update --init

################################################################################
# Common
################################################################################

CROSS_COMPILE_64	= "aarch64-linux-gnu-"
CROSS_COMPILE_32	= "arm-linux-gnueabihf-"

################################################################################
# Arm Trusted Firmware-A
################################################################################

# SPD: Secure Payload Dispatcher

TFA_PATH = $(PROJECT_ROOT)/external/arm-trusted-firmware
TFA_ENV ?= CROSS_COMPILE=$(CROSS_COMPILE_64)
#TFA_FLAGS ?= -j ARCH=aarch64 PLAT=rk3399 SPD=opteed LOG_LEVEL=50
TFA_FLAGS ?= -j ARCH=aarch64 PLAT=rk3399 SPD=opteed LOG_LEVEL=40
TFA_ELF = $(TFA_PATH)/build/rk3399/release/bl31/bl31.elf

.PHONY: arm-tfa
arm-tfa:
	$(TFA_ENV) $(MAKE) -C $(TFA_PATH) $(TFA_FLAGS) bl31
	cp $(TFA_ELF) $(PROJECT_ROOT)/output/

.PHONY: arm-tfa-clean
arm-tfa-clean:
	$(TFA_ENV) $(MAKE) -C $(TFA_PATH) $(TFA_FLAGS) clean
	rm -f $(PROJECT_ROOT)/output/bl31.elf

################################################################################
# OP-TEE OS: secure side operating system
################################################################################
OPTEE_OS_PATH			=  $(PROJECT_ROOT)/external/optee_os
OPTEE_OS_TA_DEV_KIT_DIR		?= $(OPTEE_OS_PATH)/out/arm-plat-rockchip/export-ta_arm32
OPTEE_OS_COMMON_EXTRA_FLAGS	+= CFG_USER_TA_TARGETS="ta_arm64 ta_arm32"
OPTEE_OS_COMMON_EXTRA_FLAGS	+= CFG_ARM64_core=y
OPTEE_OS_TA_CROSS_COMPILE_FLAGS += CROSS_COMPILE_ta_arm64=$(CROSS_COMPILE_64)
OPTEE_OS_TA_CROSS_COMPILE_FLAGS += CROSS_COMPILE_ta_arm32=$(CROSS_COMPILE_32)

OPTEE_OS_FLAGS ?= \
		  $(OPTEE_OS_COMMON_EXTRA_FLAGS) \
		  PLATFORM=rockchip-rk3399 \
		  CROSS_COMPILE=$(CROSS_COMPILE_64) \
		  CROSS_COMPILE_core=$(CROSS_COMPILE_64) \
		  $(OPTEE_OS_TA_CROSS_COMPILE_FLAGS) \
		  CFG_EARLY_TA=y \
		  CFG_TEE_CORE_LOG_LEVEL=3

optee_os:
	$(MAKE) -C $(OPTEE_OS_PATH) $(OPTEE_OS_FLAGS) ta_dev_kit

optee_os_clean:
	$(MAKE) -C $(OPTEE_OS_PATH) $(OPTEE_OS_FLAGS) clean

################################################################################
# Default configuration for MS fTPM TA
# https://github.com/microsoft/MSRSec
################################################################################

################################################################################
# Latest buildable wolfssl is at hash:
# 0747a16893c403fa9937963b2379cd07c0709d8b
# wolfssl breaks at hash
# 26673a0f28b85d77467a701a8c5615920eaf4ff6
# FIXME: 
# wolf_symlink/wolfcrypt/src/ecc.c:4062: undefined reference to `XSTRCASECMP'
################################################################################

FTPM_PATH =	$(PROJECT_ROOT)/external/MSRSec/TAs/optee_ta/fTPM
FTPM_UUID =	bc50d971-d4c9-42c4-82cb-343fb7f37896
FTPM_TA_NAME =	$(FTPM_UUID).stripped.elf
FTPM_TA_PATH =	$(PROJECT_ROOT)/external/MSRSec/TAs/optee_ta/out/fTPM/$(FTPM_TA_NAME)
FTPM_ENV_FLAGS ?= CFG_ARM64_core=y \
		  CFG_FTPM_USE_WOLF=y \
		  CFG_TEE_TA_LOG_LEVEL=4 \
		  CFG_TA_DEBUG=y \
		  CFG_TA_MEASURED_BOOT=y \
		  TA_PLATFORM=rockchip-rk3399 \
		  TA_CPU=cortex-a53 \
		  TA_CROSS_COMPILE=$(CROSS_COMPILE_32) \
		  TA_DEV_KIT_DIR=$(OPTEE_OS_TA_DEV_KIT_DIR)

.PHONY: ftpm
ftpm:
	cd external/MSRSec/external/wolfssl/ && \
		git checkout 0747a16893c403fa9937963b2379cd07c0709d8b
	$(FTPM_ENV_FLAGS) $(MAKE) -C $(FTPM_PATH)
	cp $(FTPM_TA_PATH) $(PROJECT_ROOT)/output/

.PHONY: ftpm-clean
ftpm-clean:
	$(FTPM_ENV_FLAGS) $(MAKE) -C $(FTPM_PATH) clean

################################################################################
# OP-TEE OS with fTPM as early TA
# More on early TA:
# https://github.com/OP-TEE/optee_os/commit/d0c636148b3a
################################################################################
OPTEE_OS_FLAGS ?= \
	$(OPTEE_OS_COMMON_EXTRA_FLAGS) \
	PLATFORM=rockchip-rk3399 \
	CROSS_COMPILE=$(CROSS_COMPILE_64) \
	CROSS_COMPILE_core=$(CROSS_COMPILE_64) \
	$(OPTEE_OS_TA_CROSS_COMPILE_FLAGS) \
	EARLY_TA_PATHS=$(PROJECT_ROOT)/output/$(FTPM_TA_NAME) \
	CFG_TEE_CORE_LOG_LEVEL=3 \
	CFG_TEE_TA_LOG_LEVEL=3

OPTEE_OS_ENV ?= \
	MEASURED_BOOT=y \
	MEASURED_BOOT_FTPM=y

optee-os-withTA:
	$(OPTEE_OS_ENV) $(MAKE) -C $(OPTEE_OS_PATH) $(OPTEE_OS_FLAGS)
	echo $(PROJECT_ROOT)/output/$(FTPM_TA_NAME)
	cp $(OPTEE_OS_PATH)/out/arm-plat-rockchip/core/tee.bin \
		$(PROJECT_ROOT)/output/

optee-os-withTA-clean:
	$(MAKE) -C $(OPTEE_OS_PATH) $(OPTEE_OS_FLAGS) clean

################################################################################
# U-Boot
################################################################################

#UBOOT_PATH =	$(PROJECT_ROOT)/external/u-boot-cbl
UBOOT_PATH =	$(PROJECT_ROOT)/external/u-boot
UBOOT_ENV ?= \
	     BL31=$(PROJECT_ROOT)/output/bl31.elf \
	     TEE=$(PROJECT_ROOT)/output/tee.bin \
	     ARCH=arm64

UBOOT_FLAGS ?= \
	     CROSS_COMPILE=$(CROSS_COMPILE_64)

# XXX to be done
configure-u-boot:
	rm -f $(PROJECT_ROOT)/output/{idbloader.img,u-boot.itb}
	$(UBOOT_ENV) $(MAKE) -C $(UBOOT_PATH) $(UBOOT_FLAGS) distclean
	$(UBOOT_ENV) $(MAKE) -C $(UBOOT_PATH) $(UBOOT_FLAGS) pinephone-pro-rk3399_tee_defconfig

u-boot:
	$(UBOOT_ENV) $(MAKE) -C $(UBOOT_PATH) $(UBOOT_FLAGS)  -j4 all
	cp $(UBOOT_PATH)/idbloader.img $(PROJECT_ROOT)/output/
	cp $(UBOOT_PATH)/u-boot.itb    $(PROJECT_ROOT)/output/

################################################################################
# Misc
################################################################################

clean-all: arm-tfa-clean optee_os_clean ftpm-clean configure-u-boot
all: arm-tfa optee_os ftpm optee-os-withTA configure-u-boot u-boot


write-sd:
	sudo dd if=$(PROJECT_ROOT)/output/idbloader.img of=/dev/sdb seek=64     oflag=direct,sync status=progress
	sudo dd if=$(PROJECT_ROOT)/output/u-boot.itb    of=/dev/sdb seek=16384  oflag=direct,sync status=progress
	sudo sync; sleep 1

