#!/bin/bash
##############################################################################
#	
# Copyright (c) 2015 Mark Charlebois (charlebm@gmail.com)
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the
#   distribution.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE.  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
##############################################################################

#
# Note: This script is run as root
#

export TOPDIR=$1
export LINAROIMG=$2
export DEBIANISO=$3
export DEBDIR=$4

shift
shift
shift
shift

echo "TOPDIR:     ${TOPDIR}"
echo "LINAROIMG:  ${LINAROIMG}"
echo "DEBIANISO:  ${DEBIANISO}"
echo "DEBDIR:     ${DEB}"

# create the mount points
mkdir -p debian-iso
mkdir -p debian_root_loop

# mount the Debian ISO
mount -o loop,ro,noexec ${DEBIANISO} debian-iso

# mount the disk image to write to
mount -o loop debian-root debian_root_loop

# Run qemu-debootstrap 
grml-debootstrap --force -v -i ${TOPDIR}/debian-iso --arch arm64 \
	--nokernel --defaultinterfaces --target debian_root_loop \
	-c ./debootstrap/config --packages ./debootstrap/packages 

# Copy the firmware to the Debian image
mkdir -p linaro_root_loop
mount -o loop,ro,noexec ${LINAROIMG} linaro_root_loop
cp -ar linaro_root_loop/lib/firmware/* debian_root_loop/lib/firmware
unmount linaro_root_loop
unmount debian_root_loop
unmount debian-iso
