#!/bin/bash
STITCHING_SCRIPT="${1}" || 'autostitch.sh'
IMG_PATH="${2}"
S_PATH="$(realpath "$(dirname $0)")"
i=0
for dir in "${IMG_PATH}"*/ ; do
   #dir=$(realpath "${dir}")
   #echo 'dir: ' "${dir}"
   #echo 'dest: ' "${dir}""${STITCHING_SCRIPT}"
    cp "${S_PATH}"/"${STITCHING_SCRIPT}" "${dir}"/"${STITCHING_SCRIPT}"
    cd "${dir}"
    ./"${STITCHING_SCRIPT}"
    mv final.jpg "$(basename "$(pwd)")".jpg
   #echo "$(basename "$(pwd)")".jpg 
    #"${d%/}" is the directory name with the trailing "/"" removed
    cd "${S_PATH}"
    i=$((i + 1))
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt '1 day ago' | wc -l) 'pano created'
