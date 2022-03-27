#!/bin/bash

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

"${pto_gen}" --projection=3 --fov=125 --stacklength=1 --output=autobase.pto APN0.jpg APN1.jpg APN2.jpg APN3.jpg APN4.jpg APN5.jpg
"${pto_var}" --set=p0=-12,y0=0,p1=-12,y1=90,p2=-12,y2=180,p3=-12,y3=-90,p4=45,y4=90,p5=45,y5=-90,a=0.0248756,b=-0.033,c=0.0524907 --modify-opt -o autobase2.pto autobase.pto
"${pto_lensstack}" --new-lens i1,i2,i3,i4,i5 -o autobase3.pto autobase2.pto
"${pto_var}" --opt=r0,p0,v0,v,!Ra,!Rb,!Rc,!Rd,!Rd,!Re,Eev,Er,Eb,Vc,Vd,!Er0,!Eb0 --modify-opt -o autobase4.pto autobase3.pto
"${vig_optimize}" -o autobase5.pto autobase4.pto
"${cpfind}" --prealigned --celeste --sieve1width 20 --sieve1height 20 --sieve1size 200 --kdtreesteps 300 -o default1.pto autobase5.pto
"${linefind}" --image=0 --image=1 --image=2 --image=3 -o default2.pto default1.pto
"${cpclean}" -o default3.pto default2.pto
"${autooptimiser}" -l -n -o default4.pto default3.pto
"${pano_modify}" --straighten -o default5.pto default4.pto
#"${pano_modify}" --rotate=0,-6,0 -o default5.pto default5.pto
sed -i '/#hugin_blender enblend/c\#hugin_blender internal' default5.pto
sed -i '/#hugin_verdandiOptions/c\#hugin_verdandiOptions --seam=blend' default5.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=1 --ldr-file=JPG --ldr-compression=95 --canvas=13340x6670 -o final.pto default5.pto
"${hugin_executor}" final.pto --stitching
"${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -SubSecTimeOriginal -Make=STFMANI -Model=V6MPack final.jpg -overwrite_original