#!/bin/bash
STITCHING_SCRIPT="${1}" || 'autostitch.sh'
S_PATH="$(realpath "$(dirname $0)")"
i=1
for dir in */ ; do
    cp "${S_PATH}"/"${STITCHING_SCRIPT}" "${dir}"/"${STITCHING_SCRIPT}"
    cd "${dir}"
    ./"${STITCHING_SCRIPT}"
    mv final.jpg "${dir%/}".jpg
    #"${d%/}" is the directory name with the trailing "/"" removed
    cd ..
    i=$((i + 1))
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt '1 day ago' | wc -l) 'pano created'