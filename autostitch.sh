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

"${pto_gen}" --projection=3 --fov=125 --stacklength=1 --output=autobase.pto APN0.jpg APN1.jpg APN2.jpg APN3.jpg APN4.jpg APN5.jpg
"${pto_var}" --set=p0=-12,y0=0,p1=-12,y1=90,p2=-12,y2=180,p3=-12,y3=-90,p4=45,y4=90,p5=45,y5=-90,a=0.0248756,b=-0.033,c=0.0524907 --opt=Eev,r0,p0,v0,v,a,b,c --modify-opt --unlink=v0,Ra0,Rb0,Rc0,Rd0,Re0,a0,b0,c0,d0,g0,t0,Va0,Vb0,Vc0,Vd0,Vx0,Vy0 -o autobase2.pto autobase.pto
"${pto_var}" --opt=Er1,Eb1,Er2,Eb2,Er3,Eb3,Er4,Eb4,Er5,Eb5,r0,p0,v0,v --modify-opt --unlink=v0,Ra0,Rb0,Rc0,Rd0,Re0,a0,b0,c0,d0,g0,t0,Va0,Vb0,Vc0,Vd0,Vx0,Vy0 -o autobase3.pto autobase2.pto
"${pano_modify}" --output-exposure=AUTO --output-range-compression=2 --ldr-file=JPG --ldr-compression=95 --canvas=13340x6670 -o autobase4.pto autobase3.pto
"${cpfind}" --prealigned --sieve1width 25 --sieve1height 25 --sieve1size 625 --kdtreesteps 300 -o default1.pto autobase4.pto
#"${linefind}" --image=0 --image=1 --image=2 --image=3 -o default2.pto default1.pto
"${cpclean}" -o default3.pto default2.pto
"${autooptimiser}" -m -l -n -o default4.pto default3.pto
"${pano_modify}" --straighten -o default5.pto default4.pto
"${hugin_executor}" default5.pto --stitching
"${exiftool}" -TagsFromFile APN0.jpg -DateTimeOriginal -Make=STFMANI -Model=V6MPack default4.jpg -overwrite_original

