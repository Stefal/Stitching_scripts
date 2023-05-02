#!/bin/bash
# Script to modify Yaw/Pitch/Roll on all final.pto files
# Then we can use the relaunch.sh command to restitch the pano

# Detect if we use WSL. If yes, use the Hugin windows release
if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ];
then
    export pto_gen='/mnt/c/Program Files/Hugin/bin/pto_gen.exe'
    export pto_var='/mnt/c/Program Files/Hugin/bin/pto_var.exe'
    export pano_modify='/mnt/c/Program Files/Hugin/bin/pano_modify.exe'
    export cpfind='/mnt/c/Program Files/Hugin/bin/cpfind.exe'
    export linefind='/mnt/c/Program Files/Hugin/bin/linefind.exe'
    export cpclean='/mnt/c/Program Files/Hugin/bin/cpclean.exe'
    export autooptimiser='/mnt/c/Program Files/Hugin/bin/autooptimiser.exe'
    export hugin_executor='/mnt/c/Program Files/Hugin/bin/hugin_executor.exe'
    export exiftool='/mnt/c/Photos_OSM/exiftool/exiftool.exe'
    export pto_lensstack='/mnt/c/Program Files/Hugin/bin/pto_lensstack.exe'
    export vig_optimize='/mnt/c/Program Files/Hugin/bin/vig_optimize.exe'
    export checkpto='/mnt/c/Program Files/Hugin/bin/checkpto.exe'
else
    export pto_gen=$(which pto_gen)
    export pto_var=$(which pto_var)
    export pano_modify=$(which pano_modify)
    export cpfind=$(which cpfind)
    export linefind=$(which linefind)
    export cpclean=$(which cpclean)
    export autooptimiser=$(which autooptimiser)
    export hugin_executor=$(which hugin_executor)
    export exiftool=$(which exiftool)
    export pto_lensstack=$(which pto_lensstack)
    export vig_optimize=$(which vig_optimize)
    export checkpto=$(which checkpto)
fi

#use these Y/P/R variables to rotate the pano
export Yaw=0
export Pitch=0
export Roll=-1
export Vb_Count=0
export Ev_Count=0
export Vb_max=5
export Fov_max=130
export Fov_mini=120

# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }
# --- Begin Code Execution Section ---



S_PATH="$(realpath "$(dirname $0)")"
i=1
for dir in */ ; do
    cd "${dir}"
    "${pano_modify}" --rotate=$Yaw,$Pitch,$Roll -o final.pto final.pto
    cd ..
    i=$((i + 1))
done
echo $i 'folders managed'
