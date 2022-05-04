#!/bin/bash
S_PATH="$(realpath "$(dirname $0)")"

 for dir in */ ; do
    if ! $(ls "${dir}"/"${dir%/}".jpg > /dev/null 2>&1)
    then
        echo 'missing pano in ' "${dir}"
        cp "${S_PATH}"/autostitch.sh "${dir}"/autostitch.sh
        cd "${dir}"
        ./autostitch.sh
        mv final.jpg "${dir%/}".jpg
        #"${d%/}" is the directory name with the trailing "/"" removed
        cd ..
    fi
done