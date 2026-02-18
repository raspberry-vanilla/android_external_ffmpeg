#!/bin/bash

# Copyright (C) 2026 KonstaKANG

for DIR in "libavcodec" "libavformat" "libavutil" "libswresample" "libswscale"; do
  echo "Parsing $DIR..."
  pushd $DIR >/dev/null 2>&1
  ./android-srcs.sh
  popd >/dev/null 2>&1
done
