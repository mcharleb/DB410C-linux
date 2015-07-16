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
# Build and flash a Debian jessie for arm64 on DB410c
#
# root password is root
#

TOPDIR:=`pwd`

DEPS:=wget grml-debootstrap qemu-debootstrap img2simg
SHARED:=../shared
DEBSDIR:=$(SHARED)/debs
IMGDIR:=$(SHARED)/images
LINAROIMG:=linaro-vivid-developer-qcom-snapdragon-arm64-20150618-47.img
LINARORAWIMG:=$(LINAROIMG).raw
DEBIANISO:=debian-8.1.0-arm64-netinst.iso
BOOTIMG:=boot-linaro-vivid-qcom-snapdragon-arm64-20150618-47.img

all: debian-rootfs.img

check-deps:
	@for d in $(DEPS); do \
		which $$d > /dev/null || echo "Missing $$d"; \
	done

install-deps:
	sudo apt-get install wget grml-debootstrap qemu-user-static android-tools-fsutils


$(LINAROIMG):
	wget https://builds.96boards.org/releases/dragonboard410c/linaro/ubuntu/15.06/$(LINAROIMG).gz
	gzip -d $(LINAROIMG).gz

$(IMGDIR)/$(LINARORAWIMG): $(LINAROIMG)
	simg2img $< $@

debian-root:
	truncate -s 3G $@
	mkfs.ext4 $@

$(DEBIANISO):
	wget http://cdimage.debian.org/debian-cd/8.1.0/arm64/iso-cd/$(DEBIANISO)

$(DEBSDIR)/linux-headers-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb:
	cd $(DEBSDIR) && wget https://builds.96boards.org/releases/dragonboard410c/linaro/ubuntu/15.06/linux-headers-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb

$(DEBSDIR)/linux-image-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb:
	cd $(DEBSDIR) && wget https://builds.96boards.org/releases/dragonboard410c/linaro/ubuntu/15.06/linux-image-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb

$(DEBSDIR)/linux-libc-dev_4.0.0-linaro-lt-qcom-1_arm64.deb:
	cd $(DEBSDIR) && wget https://builds.96boards.org/releases/dragonboard410c/linaro/ubuntu/15.06/linux-libc-dev_4.0.0-linaro-lt-qcom-1_arm64.deb

debian-root.complete: $(DEBIANISO) debian-root $(IMGDIR)/$(LINARORAWIMG) \
	$(DEBSDIR)/linux-headers-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb \
	$(DEBSDIR)/linux-image-4.0.0-linaro-lt-qcom_4.0.0-linaro-lt-qcom-1_arm64.deb \
	$(DEBSDIR)/linux-libc-dev_4.0.0-linaro-lt-qcom-1_arm64.deb
	sudo debootstrap/wrapper.sh $(TOPDIR) $(IMGDIR)/$(LINARORAWIMG) $(DEBIANISO) $(DEBSDIR)
	touch $@

debian-rootfs.img: debian-root.complete
	img2simg debian-root $@

$(IMGDIR)/$(BOOTIMG):
	wget https://builds.96boards.org/releases/dragonboard410c/linaro/ubuntu/15.06/$(BOOTIMG).gz
	gzip -d $(BOOTIMG).gz
	mv $(BOOTIMG) $(IMGDIR)/$(BOOTIMG)

flashall: $(BOOTIMG)
	sudo fastboot flash boot $(IMGDIR)/$(BOOTIMG)
	sudo fastboot flash rootfs debian-rootfs.img

clean:
	rm -f debian-root.complete debian-rootfs.img debian-root $(LINAROIMG).gz $(LINAROIMG)
	if [ -d debian_root_loop ]; then rmdir debian_root_loop; fi
	if [ -d linaro_root_loop ]; then rmdir linaro_root_loop; fi
	if [ -d debian-iso ]; then rmdir debian-iso; fi

