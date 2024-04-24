#!/bin/sh


# Patch dtb
# This repository contains dtb extracted from a mobian image, and attempts to
# add a reserved-memory node to make sure the Linux kernel will not map the
# physical memory used by optee. This hack should be removed when dtb
# injection becomes possible from optee side.
# 
# ref: https://github.com/Linaro/meta-ledge/pull/297/

# XXX automate this.

main() {
  extract_dtb
  patch_dtb
}

extract_dtb() {
  true
}

patch_dtb() {
  # decompile dtb to generate dts
  dtc -I dtb -O dts -o rk3399-pinephone-pro.dts rk3399-pinephone-pro.dtb.orig 2>/dev/null
  # patch dts to add reserved-memory node and nodes for ftpm and optee
  patch ./rk3399-pinephone-pro.dts < ./declear_reserved_memory_for_optee.patch
  patch ./rk3399-pinephone-pro.dts < ./add_nodes_for_ftpm_and_optee.patch
  # recompile dts to generate dtb
  dtc -I dts -O dtb -o rk3399-pinephone-pro.dtb rk3399-pinephone-pro.dts 2>/dev/null
  # save result and clean up
  mv rk3399-pinephone-pro.dtb ../../output/
  rm rk3399-pinephone-pro.dts
}

main "$@"
