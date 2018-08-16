#!/bin/bash

CMTKDIR="/home/emily/cmtk"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/channel_registration/refbrain/REF-1.nrrd"

echo "----------GETTING NUM SLICES------------------"
#GET NUM SLICES
#$IJ --headless -macro "$REGDIR/analysis/get_slices.ijm"

#split channels and save relevant channels
echo "------------SPLITTING STACKS-------------"
#$IJ --headless -macro "$REGDIR/analysis/split_master.ijm"

while IFS='' read -r line || [[ -n "$line" ]]; do
    slices+=($line)
done < "$REGDIR/analysis/slices.txt"


slice_index=0
for dir in $IMDIR/*;
do
    other_channel=()
    i=true
    for file in $dir/*40C1-.tif; do
        [ -e "$file" ] || continue
        other_channel+=($file)
    done
    for file in $dir/*40C3-.tif; do
        [ -e "$file" ] || continue
        other_channel+=($file)
    done    
    for file in $dir/*C2-.tif;
    do
        if $i
        then
            slices_25=${slices[slice_index]}
            fixed_filepath="$file"
            i=false
            slice_index=$(($slice_index + 1))
        else
            slices_40=${slices[slice_index]}
            moving_filepath="$file"
            i=true
            slice_index=$(($slice_index + 1))
        fi
    done
        python $REGDIR/analysis/high_low_reg/zstack2zstack_registration.py $slices_25 $slices_40 $fixed_filepath $moving_filepath $dir "xformed" $other_channel
done
