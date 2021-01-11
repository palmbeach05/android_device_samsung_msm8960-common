#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

BOARD_COMMON=msm8960-common

DEVICES_MSM8960="apexqtmo comanche d2att d2bst d2cri d2csp d2mtr d2refreshspr d2spr d2tmo d2usc d2vzw espressovzw expressatt"
DEVICES_D2="d2att d2bst d2cri d2csp d2mtr d2refreshspr d2spr d2tmo d2usc d2vzw"
DEVICES_D2_GSM="d2att d2tmo"
DEVICES_D2_R530="d2cri d2csp d2usc"

DEVICES_ALL="$DEVICES_MSM8960 $DEVICES_D2 $DEVICES_D2_GSM $DEVICES_D2_R530"

VENDOR=samsung

INITIAL_COPYRIGHT_YEAR=2012

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..
DEVICE_DIR="$MY_DIR"/../$DEVICE
DEVICE_COMMON_DIR="$MY_DIR"/../$DEVICE_COMMON

# determine which blob dirs to set up
if [ -z "$SETUP_BOARD_COMMON_DIR" ]; then
    SETUP_BOARD_COMMON_DIR=1
fi

if [ -z "$SETUP_DEVICE_DIR" ]; then
    SETUP_DEVICE_DIR=0
fi

if [ -z "$SETUP_DEVICE_COMMON_DIR" ]; then
    SETUP_DEVICE_COMMON_DIR=0
fi

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

if [ "$DEVICE" == "d2att" ] ||
                [ "$DEVICE" == "d2tmo" ]; then
    export BLOB_LOC=d2gsm
elif [ "$DEVICE" == "d2cri" ] ||
                [ "$DEVICE" == "d2scp" ] ||
                [ "$DEVICE" == "d2usc" ]; then
    export BLOB_LOC=d2r530
else
    export BLOB_LOC=$DEVICE
fi

if [ "$BLOB_LOC" != "$DEVICE" ]; then
    # Reinitialize the helper for device
    setup_vendor "$BLOB_LOC" "$VENDOR" "$LINEAGE_ROOT" true

    # Copyright headers and guards
    if [ "$BLOB_LOC" == "d2gsm" ]; then
    write_headers "$D2_GSM_LIST"
    elif [ "$BLOB_LOC" == "d2r530" ]; then
    write_headers "$D2_R530_LIST"
    else
    write_headers "$DEVICE"
    fi

    # The standard device blobs
    write_makefiles $DEVICE_COMMON_DIR/proprietary-files.txt

    # We are done!
    write_footers
fi

if [ "$SETUP_DEVICE_COMMON_DIR" -eq 1 ] && [ -s $DEVICE_COMMON_DIR/proprietary-files.txt ]; then
    # Reinitialize the helper for device
    setup_vendor "$DEVICE_COMMON" "$VENDOR" "$LINEAGE_ROOT" true

    # Copyright headers and guards
    write_headers "$DEVICES"

    # The standard device blobs
    write_makefiles $DEVICE_COMMON_DIR/proprietary-files.txt

    # We are done!
    write_footers
fi

if [ "$SETUP_DEVICE_DIR" -eq 1 ] && [ -s $DEVICE_DIR/proprietary-files.txt ]; then
    # Reinitialize the helper for device
    setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT"

    # Copyright headers and guards
    write_headers

    # The standard device blobs
    write_makefiles $DEVICE_DIR/proprietary-files.txt

    # We are done!
    write_footers
fi

if  [ "$SETUP_BOARD_COMMON_DIR" -eq 1 ]; then
   # set up the board common makefiles
   DEVICE_COMMON=$BOARD_COMMON

   # Initialize the helper
   setup_vendor "$BOARD_COMMON" "$VENDOR" "$LINEAGE_ROOT" true

   # Copyright headers and guards
   write_headers "$DEVICES_ALL"

   write_makefiles "$MY_DIR"/proprietary-files.txt

   # Finish
   write_footers
fi
