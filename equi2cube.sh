#!/bin/bash

# Detect if we use WSL. If yes, use the Hugin windows release
if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ];
then
    pto_gen='/mnt/c/Program Files/Hugin/bin/pto_gen.exe'
    pto_var='/mnt/c/Program Files/Hugin/bin/pto_var.exe'
    pano_modify='/mnt/c/Program Files/Hugin/bin/pano_modify.exe'
    cpfind='/mnt/c/Program Files/Hugin/bin/cpfind.exe'
    linefind='/mnt/c/Program Files/Hugin/bin/linefind.exe'
    cpclean='/mnt/c/Program Files/Hugin/bin/cpclean.exe'
    autooptimiser='/mnt/c/Program Files/Hugin/bin/autooptimiser.exe'
    hugin_executor='/mnt/c/Program Files/Hugin/bin/hugin_executor.exe'
    exiftool='/mnt/c/Photos_OSM/exiftool/exiftool.exe'
    pto_lensstack='/mnt/c/Program Files/Hugin/bin/pto_lensstack.exe'
    vig_optimize='/mnt/c/Program Files/Hugin/bin/vig_optimize.exe'
    checkpto='/mnt/c/Program Files/Hugin/bin/checkpto.exe'
	nona='/mnt/c/Program Files/Hugin/bin/nona.exe'
else
    pto_gen=$(which pto_gen)
    pto_var=$(which pto_var)
    pano_modify=$(which pano_modify)
    cpfind=$(which cpfind)
    linefind=$(which linefind)
    cpclean=$(which cpclean)
    autooptimiser=$(which autooptimiser)
    hugin_executor=$(which hugin_executor)
    exiftool=$(which exiftool)
    pto_lensstack=$(which pto_lensstack)
    vig_optimize=$(which vig_optimize)
    checkpto=$(which checkpto)
	nona=$(which nona)
fi

S_PATH="$(realpath "$(dirname $0)")"
i=1

equi2cube() {
img=$(basename $1)
echo $img
cp cubemap_orig.pto cubemap.pto
sed -i 's|orig-pano.jpg|'"${img}"'|g' cubemap.pto
#cp "${img}" "${img:0: -4}"000Z.jpg
#${cpclean}
#return
"${nona}" -o "${img:0: -4}" cubemap.pto
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0000.jpg -overwrite_original
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0001.jpg -overwrite_original
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0002.jpg -overwrite_original
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0003.jpg -overwrite_original
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0004.jpg -overwrite_original
exiftool -TagsFromFile "${img}" -Gps:all "${img:0: -4}"0005.jpg -overwrite_original
}

equi2cube "$1"

#export -f equi2cube
#find . -exec bash -c 'dosomething "$0"' {} \;
#find "$(dirname $0)" -iname "*.jpg" -exec bash -c 'equi2cube "$0"' {} \;
#find $(pwd) -maxdepth 1 -iname "*.jpg" | while read -r file; do equi2cube "${file}"; done
#find $(pwd)  -maxdepth 1 -iname "*.jpg"| while read -r file; do echo "${file}"; done
#echo $i 'images managed'


# Use this script with a command like this:
#find . -maxdepth 1 -iname "*.jpg" -exec /mnt/d/test_cubeface/equi2cube.sh {} \;

# Edit w(width) and h(height) value in cubemap_orig.pto with the width/height of you source photo.

