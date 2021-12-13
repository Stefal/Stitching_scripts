#!/bin/bash
i=1
for dir in */ ; do
    cp autostitch.sh "${dir}"/autostitch
    cd "${dir}"
    ./autostitch
    mv default5.jpg "${d%/}".jpg
    #"${d%/}" is the directory name with the trailing "/"" removed
    cd ..
    i=$((i + 1))
done
echo $i 'folders managed'
echo $(find . -maxdepth 2 -type f -name "*.jpg" -newermt '1 day ago' | wc -l) 'pano created'