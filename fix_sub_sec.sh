#!/bin/bash

for dir in */ ; do
 cd "${dir}"
 /mnt/c/Photos_OSM/exiftool/exiftool.exe -TagsFromFile APN0.jpg -DateTimeOriginal -SubSecTimeOriginal -Make=STFMANI -Model=V6MPack "${dir%/}".jpg -overwrite_original
 cd ..
done