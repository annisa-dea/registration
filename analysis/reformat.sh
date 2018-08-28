#!/bin/bash

CMTKDIR="/home/emily/cmtk/build/bin"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/channel_registration_1/channel_registration/refbrain/REF-1.nrrd"

echo "----------------SETTING PROPERTIES OF REFORMATTED CHANNELS------------------"
$IJ --headless -macro $REGDIR/analysis/set_properties.ijm

for file in /home/emily/registration/channel_registration/Registration/warp/*; do
    warp+=($file)
done 

function reformat() {
    i=1
    for dir in $IMDIR/*; do 
        j=0
        for image in $dir/transforms/*.nrrd; do 
            echo "$dir/transforms/"$(basename $dir)"_"$j"_rfmt.nrrd"
            echo $image
            echo ${warp[$i]}
            j=$(($j + 1))
            "$CMTKDIR/reformatx" -o "$dir/transforms/"$(basename $dir)"_"$j"_rfmt.nrrd" --floating $image "$REFBRAIN" "${warp[$i]}"
        done
        i=$(($i + 1))
    done
}

reformat 
