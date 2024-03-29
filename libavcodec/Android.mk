#
# Copyright (C) 2013 The Android-x86 Open Source Project
# Copyright (C) 2023 KonstaKANG
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

LOCAL_PATH := $(call my-dir)

FFMPEG_MULTILIB := 32
include $(LOCAL_PATH)/../android/build.mk

ifeq ($(CONFIG_ZLIB),yes)
LOCAL_SHARED_LIBRARIES += libz
endif

ifeq ($(CONFIG_LIBDRM),yes)
LOCAL_SHARED_LIBRARIES += libdrm
endif

ifeq ($(CONFIG_LIBUDEV),yes)
LOCAL_SHARED_LIBRARIES += libudev
endif

ifeq ($(CONFIG_LIBDAV1D),yes)
LOCAL_SHARED_LIBRARIES += libdav1d
endif

ifneq ($(ARCH_ARM_HAVE_NEON),)
LOCAL_SRC_FILES += neon/mpegvideo.c
endif

LOCAL_CFLAGS += -Wno-enum-conversion

LOCAL_MULTILIB := $(FFMPEG_MULTILIB)
include $(BUILD_SHARED_LIBRARY)


FFMPEG_MULTILIB := 64
include $(LOCAL_PATH)/../android/build.mk

ifeq ($(CONFIG_ZLIB),yes)
LOCAL_SHARED_LIBRARIES += libz
endif

ifeq ($(CONFIG_LIBDRM),yes)
LOCAL_SHARED_LIBRARIES += libdrm
endif

ifeq ($(CONFIG_LIBUDEV),yes)
LOCAL_SHARED_LIBRARIES += libudev
endif

ifeq ($(CONFIG_LIBDAV1D),yes)
LOCAL_SHARED_LIBRARIES += libdav1d
endif

ifneq ($(ARCH_ARM_HAVE_NEON),)
LOCAL_SRC_FILES += neon/mpegvideo.c
endif

LOCAL_CFLAGS += -Wno-enum-conversion

LOCAL_MULTILIB := $(FFMPEG_MULTILIB)
include $(BUILD_SHARED_LIBRARY)
