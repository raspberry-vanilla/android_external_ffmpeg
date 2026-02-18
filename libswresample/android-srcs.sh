#!/bin/bash

# Copyright (C) 2026 KonstaKANG

FFMPEG_TOP=$(pwd | sed 's/ffmpeg.*$/ffmpeg/')
OPTIONS=$(cat "$FFMPEG_TOP"/ffbuild/config.mak | grep "=yes$" | sed 's/=yes$//' | sort -u)
OUTPUT="$(pwd)/android-srcs.txt"

read_makefile() {
  MAKEFILE=$(cat Makefile | sed -z 's/\\\n//g' | sed 's/\t/ /g' | sed 's/  */ /g')
}

print_source_files_to_output() {
  echo "$1" | sed 's/^.*= //' | sed "s/\.o/\.$2\n/g" | sed 's/^ //' >> ${OUTPUT}
}

parse_objs() {
  LINE=$(echo "$MAKEFILE" | grep "^$1 ")
  print_source_files_to_output "$LINE" "$2"
}

parse_objs_option() {
  LINES=$(echo "$MAKEFILE" | grep "^$1-\$(")
  echo "$LINES" | while IFS= read -r LINE; do
    OPTION=$(echo $LINE | sed "s/^$1-\$(//" | sed 's/).*$//')
    if [ ! -z $(echo "$OPTIONS" | grep -Fx "$OPTION") ]; then
      print_source_files_to_output "$LINE" "$2"
    fi
  done
}

parse_dir() {
  pushd "$1" >/dev/null 2>&1
  read_makefile
  parse_objs "OBJS" "c"
  parse_objs "SHLIBOBJS" "c"
  parse_objs "ARMV8-OBJS" "c"
  parse_objs "NEON-OBJS" "S"
  parse_objs "SVE-OBJS" "c"
  parse_objs "SVE2-OBJS" "c"
  parse_objs "SME-OBJS" "c"
  parse_objs "SME2-OBJS" "c"
  parse_objs_option "OBJS" "c"
  parse_objs_option "SHLIBOBJS" "c"
  parse_objs_option "ARMV8-OBJS" "S"
  parse_objs_option "NEON-OBJS" "S"
  parse_objs_option "SVE-OBJS" "c"
  parse_objs_option "SVE2-OBJS" "c"
  parse_objs_option "SME-OBJS" "c"
  parse_objs_option "SME2-OBJS" "S"
  popd >/dev/null 2>&1
}

# Parse Makefiles in subdirectories
parse_dir "."
parse_dir "aarch64"

# Read output to array, remove duplicates & sort
readarray -t FILES < ${OUTPUT}
UNIQ_SORTED_FILES=($(for FILE in "${FILES[@]}"; do echo "${FILE}"; done | sort -u))

# Save beginning to new makefile
CUT_LINE=$(grep -n '^    srcs: \[$' Android.bp | head -n1 | cut -d: -f1)
head -n $CUT_LINE Android.bp > Android.bp-next

# Print sources to makefile
for FILE in "${UNIQ_SORTED_FILES[@]}"; do
  echo "        \"${FILE}\"," >> Android.bp-next
done
echo "    ]," >> Android.bp-next
echo "}" >> Android.bp-next

# Format makefile
bpfmt -s -w Android.bp-next

# Cleanup
mv Android.bp-next Android.bp
rm ${OUTPUT}
