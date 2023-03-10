#
# Copyright (C) 2013-2017 The Android-x86 Open Source Project
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

FFMPEG_ARCH := $(TARGET_ARCH)

FFMPEG_2ND_ARCH := false
ifneq ($(TARGET_2ND_ARCH_VARIANT),)
   ifeq ($(FFMPEG_MULTILIB),32)
      FFMPEG_2ND_ARCH := true
   endif
endif

ifeq ($(FFMPEG_2ND_ARCH), true)
    FFMPEG_ARCH := $(TARGET_2ND_ARCH)
endif

ifeq ($(FFMPEG_ARCH),arm64)
    FFMPEG_ARCH := aarch64
endif

FFMPEG_ARCH_VARIANT := $(TARGET_ARCH_VARIANT)
ifeq ($(FFMPEG_2ND_ARCH), true)
   FFMPEG_ARCH_VARIANT := $(TARGET_2ND_ARCH_VARIANT)
endif

ifneq ($(filter x86 x86_64, $(FFMPEG_ARCH)),)
    TARGET_CONFIG := config-$(FFMPEG_ARCH)-$(FFMPEG_ARCH_VARIANT).h
    TARGET_CONFIG_ASM := config-$(FFMPEG_ARCH).asm
else
    TARGET_CONFIG := config-$(FFMPEG_ARCH_VARIANT).h
    TARGET_CONFIG_ASM := config-$(FFMPEG_ARCH_VARIANT).asm
endif

LOCAL_CFLAGS := \
	-DANDROID_SDK_VERSION=$(PLATFORM_SDK_VERSION) \
	-DTARGET_CONFIG=\"$(TARGET_CONFIG)\" \
	-DTARGET_CONFIG_ASM=$(TARGET_CONFIG_ASM) \
	-DHAVE_AV_CONFIG_H -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -DPIC \

LOCAL_ASFLAGS := $(LOCAL_CFLAGS)
