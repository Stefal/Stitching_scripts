#!/bin/bash
DELAY=$1
[[ -z $DELAY ]] && echo 'Please enter a delay like '\''1 hour ago'\' && exit 1

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
fi

i=0

for dir in $(find . -maxdepth 2 -type f -name "final.pto" -newermt "${DELAY}") ; do
    echo $(dirname $dir)
    if [ "$2" = '--stitch' ]
        then
        cd $(dirname $dir)
        "${hugin_executor}" final.pto --stitching
        "${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -SubSecTimeOriginal -Make=STFMANI -Model=V6MPack final.jpg -overwrite_original
        newname=$(dirname $dir | cut -c3-)
        mv final.jpg "${newname}".jpg
        #"${d%/}" is the directory name with the trailing "/"" removed
        cd ..
        i=$((i + 1))
    fi
    
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt "${DELAY}" | wc -l) 'pano created'
