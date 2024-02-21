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
export Vb_max=7
export Fov_max=130
export Fov_mini=120
export Roll_max=45
export Roll_min=-45
export Pano_size='9600x4800'
#export Pano_size='6000x3000'

# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }
# --- Begin Code Execution Section ---

check_Vb() {
# Check if the Vb value in the final.pto file is too high or too low
file="${1}"
export LC_NUMERIC=C
awk -v max=$2 -v min=$3 '/^i/ {for(i=1; i<=NF; i++) {if($i ~ "Vb") {gsub(/Vb/,"") ; {if( $i > max || $i < min ) print $i , err=1}}}} END {exit err}' "${file}"
#awk -v max=$2 -v min=$3 '/^i/ {for(i=1; i<=NF; i++) {if($i ~ "Vb") {gsub(/Vb/,"") ; {if( $i > max || $i < min ) print $i , err=1}}}} END {exit err}' "${file}"

}

check_Fov() {
# Check if the Fov value is too low or too high, meaning there is a problem in the pano.
file="${1}"
export LC_NUMERIC=C
awk -v max=$2 -v min=$3 '/^i/ {if(substr($5,2) > max || substr($5,2) < min) print $5 , err=1} END {exit err}' "${file}"
}

check_Roll() {
# Check if the Roll value is too low or too high, meaning there is a problem in the pano like upside down.
file="${1}"
export LC_NUMERIC=C
awk -v max=$2 -v min=$3 '/^i/ {if(substr($14,2,4)+0 > max || substr($14,2,4)+0 < min) print substr($14,2,4) , err=1} END {exit err}' "${file}"
}

test -f APN0.jpg || exit 1

"${vig_optimize}" -o base.pto template.pto
"${autooptimiser}" -l -n -o base.pto base.pto
"${vig_optimize}" -o base.pto base.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=$Pano_size -o final.pto base.pto
#Try to fix lens exposure when Vb is too high
#while ! check_Vb final.pto $Vb_max $((-Vb_max))
#do
#    "${vig_optimize}" -o final.pto final.pto
#    "${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=$Pano_size -o final.pto final.pto
#    ((Vb_Count=Vb_Count+1))
#    #touch please_check_mini
#    echo 'Vb_Count: ' $Vb_Count
#    if [ $Vb_Count -gt 5 ]
#        then
#        "${pto_var}" --set=Eev=0 -o final.pto final.pto
#        echo 'Reset Eev'
#        Vb_Count=0
#        if [ $Ev_Count > 1 ]
#            then
#            "${pto_var}" --set=Eev=0,Vb=0,Vc=0,Vd=0 -o final.pto final.pto
#            echo 'Reset Eev, Vb, Vc, Vd'
#            touch please_check_high
#        fi
#        "${vig_optimize}" -o final.pto final.pto
#        "${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=$Pano_size -o final.pto final.pto
#        ((Vb_max=Vb_max+1))
#        ((Ev_Count=Ev_Count+1))
#    fi
#done
check_Fov final.pto $Fov_max $Fov_min || touch check_fov
check_Roll final.pto $Roll_max $Roll_min || touch check_Roll
"${hugin_executor}" final.pto --stitching
"${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -SubSecTimeOriginal final.jpg -overwrite_original
