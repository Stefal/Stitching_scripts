#!/bin/bash

#launch this script with a command like 
#find . -iname "*.jpg" -exec ./resize.sh {} \;
if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ];
then
    magick='/mnt/c/Program Files/ImageMagick-7.1.0-Q16-HDRI/magick.exe'
else
:
fi

"${magick}" convert -resize x6500 "${1}" "${1}"
exiftool "-ImageDescription=" "-ExifImageHeight<ImageHeight" "-ExifImageWidth<ImageWidth" "${1}" -overwrite_original