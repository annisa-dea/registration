#!/bin/bash

CMTKDIR="/home/emily/cmtk/build/bin"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images_1"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/channel_registration_1/channel_registration/refbrain/REF-1.nrrd"

for file in /home/emily/registration/channel_registration_1/channel_registration/Registration/affine/*; do
    affine+=($file)
done 

for file in /home/emily/registration/channel_registration_1/channel_registration/Registration/warp/*; do
    warp+=($file)
done 
#$1 = affine or warp

function reformat() {
    i=0
    for dir in $IMDIR/*; do 
        for image in $dir/transforms/*.nrrd; do 
            if [ "$1" = "affine" ]
            then
            echo $image
            echo ${affine[$i]}
            #hmmmm........
            "$CMTKDIR/reformatx" -o "$dir/transforms/affine.nrrd" --floating "$image" "$REFBRAIN" "${affine[$i]}" 
            mv $image "$dir/transforms/xformed"
            else
            echo $image
            echo ${warp[$i]}
            "$CMTKDIR/reformatx" -o "$dir/transforms/warp.nrrd" --floating "$dir/transforms/affine.nrrd" "$REFBRAIN" "${warp[$i]}"
            fi
        done
        i=$(($i + 1))
    done
}

reformat "affine"
reformat "warp"
