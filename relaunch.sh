#!/bin/bash
hugin_executor='/mnt/c/Program Files/Hugin/bin/hugin_executor.exe'
exiftool='/mnt/c/Photos_OSM/exiftool/exiftool.exe'
i=1

for dir in $(find . -maxdepth 2 -type f -name "final.pto" -newermt '2 hour ago') ; do
    echo $(dirname $dir)
    cd $(dirname $dir)
    "${hugin_executor}" final.pto --stitching
    "${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -DateTimeOriginal -Make=STFMANI -Model=V6MPack final.jpg -overwrite_original
	newname=$(dirname $dir | cut -c3-)
    mv final.jpg "${newname}".jpg
    #"${d%/}" is the directory name with the trailing "/"" removed
    cd ..
    i=$((i + 1))
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt '1 day ago' | wc -l) 'pano created'
