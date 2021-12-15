#!/bin/bash
hugin_executor='/mnt/c/Program Files/Hugin/bin/hugin_executor.exe'
exiftool='/mnt/c/Photos_OSM/exiftool/exiftool.exe'
i=1

for dir in $(find . -maxdepth 2 -type f -name "default5.pto" -newermt '1 hour ago') ; do
    echo $(dirname $dir)
    cd $(dirname $dir)
    "${hugin_executor}" default5.pto --stitching
    "${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -Make=STFMANI -Model=V6MPack default5.jpg -overwrite_original
    mv final.jpg "${dir%/}".jpg
    #"${d%/}" is the directory name with the trailing "/"" removed
    cd ..
    i=$((i + 1))
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt '1 day ago' | wc -l) 'pano created'