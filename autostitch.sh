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

#use these Y/P/R variables to rotate the pano
Yaw=0
Pitch=0
Roll=0
Vb_Count=0
Ev_Count=0
Vb_max=5
Fov_max=130
Fov_mini=120

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

test -f apn0.jpg || exit 1

"${pto_gen}" --projection=3 --fov=125 --stacklength=1 --output=autobase.pto APN0.jpg APN1.jpg APN2.jpg APN3.jpg APN4.jpg APN5.jpg
"${pto_var}" --set=p0=-12,y0=0,p1=-12,y1=90,p2=-12,y2=180,p3=-12,y3=-90,p4=45,y4=90,p5=45,y5=-90,a=0.0248756,b=-0.033,c=0.0524907 --modify-opt -o autobase2.pto autobase.pto
"${pto_lensstack}" --new-lens i1,i2,i3,i4,i5 -o autobase3.pto autobase2.pto
"${pto_var}" --opt=r0,p0,v0,v,!Ra,!Rb,!Rc,!Rd,!Rd,!Re,Eev,Er,Eb,Vc,Vd,!Er0,!Eb0 --modify-opt -o autobase4.pto autobase3.pto
"${vig_optimize}" -o autobase5.pto autobase4.pto
"${cpfind}" --prealigned --sieve1width 20 --sieve1height 20 --sieve1size 200 --kdtreesteps 300 -o default1.pto autobase5.pto
#"${linefind}" --image=0 --image=1 --image=2 --image=3 -o default2.pto default1.pto
"${cpclean}" -o default2.pto default1.pto
"${checkpto}" default2.pto | grep -q 'unconnected images' && "${cpfind}" --fullscale --multirow --sieve1width=25 --sieve1height=25 --sieve1size=1000 --kdtreesteps=300 -o default2.pto default2.pto
"${autooptimiser}" -l -n -o default3.pto default2.pto
#"${pano_modify}" --straighten -o default5.pto default4.pto
"${pano_modify}" --rotate=$Yaw,$Pitch,$Roll -o default5.pto default3.pto
sed -i '/#hugin_blender enblend/c\#hugin_blender internal' default5.pto
sed -i '/#hugin_verdandiOptions/c\#hugin_verdandiOptions --seam=blend' default5.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 -o default5.pto default5.pto
"${vig_optimize}" -o default5.pto default5.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=13340x6670 -o final.pto default5.pto
#Try to fix lens exposure when Vb is too high
while ! check_Vb final.pto $Vb_max $((-Vb_max))
do
    "${vig_optimize}" -o final.pto final.pto
    "${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=13340x6670 -o final.pto final.pto
    ((Vb_Count=Vb_Count+1))
    touch please_check_mini
    echo 'Vb_Count: ' $Vb_Count
    if [ $Vb_Count -gt 5 ]
        then
        "${pto_var}" --set=Eev=0 -o final.pto final.pto
        echo 'Reset Eev'
        Vb_Count=0
        if [ $Ev_Count > 1 ]
            then
            "${pto_var}" --set=Eev=0,Vb=0,Vc=0,Vd=0 -o final.pto final.pto
            echo 'Reset Eev, Vb, Vc, Vd'
            touch please_check_high
        fi
        "${vig_optimize}" -o final.pto final.pto
        "${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=90 --canvas=13000x6500 -o final.pto final.pto
        ((Vb_max=Vb_max+1))
        ((Ev_Count=Ev_Count+1))
    fi
done
check_Fov final.pto $Fov_max $Fov_min || touch check_fov
"${hugin_executor}" final.pto --stitching
"${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -SubSecTimeOriginal -Make=STFMANI -Model=V6MPack final.jpg -overwrite_original
