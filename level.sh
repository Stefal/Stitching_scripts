#!/bin/bash

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
export Roll=0
export Vb_Count=0
export Ev_Count=0
export Vb_max=5
export Fov_max=132
export Fov_mini=118
export Roll_max=45
export Roll_min=-45
export Pano_size='13000x6500'
#export Pano_size='4000x2000'

# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }
# --- Begin Code Execution Section ---

"${pano_modify}" --rotate=$Yaw,$Pitch,$Roll -o default.pto default.pto
sed -i '/#hugin_blender enblend/c\#hugin_blender internal' default5.pto
sed -i '/#hugin_verdandiOptions/c\#hugin_verdandiOptions --seam=blend' default5.pto
sed -i '/#hugin_edgeFillMode/c\#hugin_edgeFillMode 1' default5.pto
sed -i '/#hugin_edgeFillKeepInput/c\#hugin_edgeFillKeepInput false' default5.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 -o default.pto default.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=92 --canvas=$Pano_size -o final.pto default5.pto
"${hugin_executor}" final.pto --stitching --prefix=$1_level
"${exiftool}" -TagsFromFile $1 -DateTimeOriginal -SubSecTimeOriginal $1_level -overwrite_original
