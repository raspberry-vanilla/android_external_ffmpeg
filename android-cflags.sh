#!/bin/bash

# Copyright (C) 2026 KonstaKANG

# Read flags
CPPFLAGS=$(cat ffbuild/config.mak | grep "^CPPFLAGS=" | sed 's/^CPPFLAGS= *//')
CFLAGS=$(cat ffbuild/config.mak | grep "^CFLAGS=" | sed 's/^CFLAGS= *//')
CXXFLAGS=$(cat ffbuild/config.mak | grep "^CXXFLAGS=" | sed 's/^CXXFLAGS= *//')
LDFLAGS=$(cat ffbuild/config.mak | grep "^LDFLAGS=" | sed 's/^LDFLAGS= *//')
SHFLAGS=$(cat ffbuild/config.mak | grep "^SHFLAGS=" | sed 's/^SHFLAGS= *//')
ASFLAGS=$(cat ffbuild/config.mak | grep "^ASFLAGS=" | sed 's/^ASFLAGS= *//')

# Add flags to array
CFLAGS_ALL=($CPPFLAGS)
CFLAGS_ALL+=($CFLAGS)
CFLAGS_ALL+=($CXXFLAGS)
LDFLAGS_ALL=($LDFLAGS)
LDFLAGS_ALL+=($SHFLAGS)
ASFLAGS_ALL=($ASFLAGS)

# Remove duplicates & sort
CFLAGS_SORTED=($(for FLAG in "${CFLAGS_ALL[@]}"; do echo "${FLAG}"; done | sort -u))
LDFLAGS_SORTED=($(for FLAG in "${LDFLAGS_ALL[@]}"; do echo "${FLAG}"; done | sort -u))
ASFLAGS_SORTED=($(for FLAG in "${ASFLAGS_ALL[@]}"; do echo "${FLAG}"; done | sort -u))

# Print flags
echo "    cflags: ["
for FLAG in "${CFLAGS_SORTED[@]}"; do
  echo "        \"${FLAG}\","
done
echo "    ],"

echo "    ldflags: ["
for FLAG in "${LDFLAGS_SORTED[@]}"; do
  echo "        \"${FLAG}\","
done
echo "    ],"

echo "    asflags: ["
for FLAG in "${ASFLAGS_SORTED[@]}"; do
  echo "        \"${FLAG}\","
done
echo "    ],"
