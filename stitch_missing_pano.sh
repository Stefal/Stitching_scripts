#!/bin/bash
S_PATH="$(realpath "$(dirname $0)")"
i=0
 for dir in */ ; do
    if ! $(ls "${dir}"/"${dir%/}".jpg > /dev/null 2>&1)
    then
        echo 'missing pano in ' "${dir}""${dir%/}"'.jpg'
        i=$((i + 1)) 
        #echo '$1: ' $1
        if [ "$1" = '--stitch' ]
            then
            echo 'dans le if'
            cp "${S_PATH}"/autostitch.sh "${dir}"/autostitch.sh
            cd "${dir}"
            ./autostitch.sh
	        mv final.jpg "${dir%/}".jpg
            cd ..
        fi
        ##"${d%/}" is the directory name with the trailing "/"" removed
    fi
done
echo 'Missing panos: ' $i