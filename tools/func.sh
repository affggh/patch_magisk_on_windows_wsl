#!/system/bin/sh
#######################################################################################
# Magisk Boot Image Patcher
#######################################################################################
#
# Usage: boot_patch.sh <bootimage>
#
# The following flags can be set in environment variables:
# KEEPVERITY, KEEPFORCEENCRYPT, RECOVERYMODE
#
# This script should be placed in a directory with the following files:
#
# File name          Type      Description
#
# boot_patch.sh      script    A script to patch boot image for Magisk.
#                  (this file) The script will use files in its same
#                              directory to complete the patching process
# util_functions.sh  script    A script which hosts all functions required
#                              for this script to work properly
# magiskinit         binary    The binary to replace /init
# magisk(32/64)      binary    The magisk binaries
# ./flinux ./magiskboot         binary    A tool to manipulate boot images
# chromeos           folder    This folder includes the utility and keys to sign
#                  (optional)  chromeos boot images. Only used for Pixel C.
#
#######################################################################################

############
# Functions
############

# Pure bash dirname implementation
getdir() {
  case "$1" in
    */*)
      dir=${1%/*}
      if [ -z $dir ]; then
        echo "/"
      else
        echo $dir
      fi
    ;;
    *) echo "." ;;
  esac
}
# added by affggh
ui_print() {
  if $BOOTMODE; then
    echo "$1"
  else
    echo -e "ui_print $1\nui_print" >> /proc/self/fd/$OUTFD
  fi
}
abort() {
  ui_print "$1"
  $BOOTMODE || recovery_cleanup
  [ ! -z $MODPATH ] && rm -rf $MODPATH
  rm -rf $TMPDIR
  exit 1
}
# this will not use by normal devices and it wont work on windows
sign_chromeos() {
  ui_print "- Signing ChromeOS boot image"

  echo > empty
  ./chromeos/futility vbutil_kernel --pack new-boot.img.signed \
  --keyblock ./chromeos/kernel.keyblock --signprivate ./chromeos/kernel_data_key.vbprivk \
  --version 1 --vmlinuz new-boot.img --config empty --arch arm --bootloader empty --flags 0x1

  rm -f empty new-boot.img
  mv new-boot.img.signed new-boot.img
}
#################
# Initialization
#################

if [ -z $SOURCEDMODE ]; then
  # Switch to the location of the script file
  cd "$(getdir "${BASH_SOURCE:-$0}")"
  # Load utility functions
  # ##disable another functions
  #. ./util_functions.sh
  # Check if 64-bit
  #api_level_arch_detect
  #ARCH=arm64
  #ARCH32=arm
  #IS64BIT=true
fi

BOOTIMAGE="$1"
[ -e "$BOOTIMAGE" ] || abort "$BOOTIMAGE does not exist!"

