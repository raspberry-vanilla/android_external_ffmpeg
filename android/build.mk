#
# Copyright (C) 2013-2017 The Android-x86 Open Source Project
# Copyright (C) 2023 KonstaKANG
#
# Licensed under the GNU General Public License Version 2 or later.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses/gpl.html
#

FFDROID_DIR := $(FFMPEG_DIR)/android

include $(CLEAR_VARS)

$(foreach V,$(FF_VARS),$(eval $(call RESET,$(V))))
#$(warning INCLUDING $(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH)/Makefile) for $(FFMPEG_2ND_ARCH) - $(NEON-OBJS) - $(FF_VARS))

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

ifeq ($(FFMPEG_ARCH),arm)
FFMPEG_ARCH_VARIANT := armv7-a-neon
endif

TARGET_CONFIG := config-$(FFMPEG_ARCH_VARIANT).h

include $(FFDROID_DIR)/config-$(FFMPEG_ARCH_VARIANT).mak
include $(LOCAL_PATH)/Makefile $(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH)/Makefile)
include $(FFMPEG_DIR)/ffbuild/arch.mak

# remove duplicate objects
OBJS := $(sort $(OBJS) $(OBJS-yes))

ALL_S_FILES := $(subst $(LOCAL_PATH)/,,$(wildcard $(LOCAL_PATH)/$(FFMPEG_ARCH)/*.S))

ifneq ($(ALL_S_FILES),)
S_OBJS := $(ALL_S_FILES:%.S=%.o)
C_OBJS := $(filter-out $(S_OBJS),$(OBJS))
S_OBJS := $(filter $(S_OBJS),$(OBJS))
else
C_OBJS := $(OBJS)
S_OBJS :=
endif

C_FILES := $(C_OBJS:%.o=%.c)
S_FILES := $(S_OBJS:%.o=%.S)

LOCAL_ARM_MODE := arm
LOCAL_MODULE := lib$(NAME)
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_VENDOR_MODULE := true

LOCAL_SRC_FILES := \
    $(C_FILES) \
    $(S_FILES)

LOCAL_C_INCLUDES := \
    $(FFDROID_DIR)/include \
    $(FFMPEG_DIR)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_C_INCLUDES)

# Base flags
LOCAL_CFLAGS := \
    -DANDROID_SDK_VERSION=$(PLATFORM_SDK_VERSION) \
    -DTARGET_CONFIG=\"$(TARGET_CONFIG)\" \
    -DHAVE_AV_CONFIG_H -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -DPIC

LOCAL_ASFLAGS := \
    $(LOCAL_CFLAGS)

LOCAL_CFLAGS += \
    -O3 -std=c99 -fno-math-errno -fno-signed-zeros -fomit-frame-pointer -fPIC

# Warnings disabled by FFMPEG
LOCAL_CFLAGS += \
    -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign \
    -Wno-unused-const-variable -Wno-bool-operation -Wno-deprecated-declarations \
    -Wno-unused-variable

# Additional flags required for AOSP/clang
LOCAL_CFLAGS += \
    -Wno-unused-parameter -Wno-missing-field-initializers \
    -Wno-incompatible-pointer-types-discards-qualifiers -Wno-sometimes-uninitialized \
    -Wno-unneeded-internal-declaration -Wno-initializer-overrides -Wno-string-plus-int \
    -Wno-absolute-value -Wno-constant-conversion

LOCAL_LDFLAGS := -Wl,--no-fatal-warnings -Wl,-Bsymbolic

LOCAL_CLANG_CFLAGS += -Wno-unknown-attributes -Wno-inline-asm

LOCAL_SHARED_LIBRARIES := $($(NAME)_FFLIBS:%=lib%)
