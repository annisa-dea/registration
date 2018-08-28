#!/bin/bash
#20170726
#emily


CMTKDIR="/home/emily/cmtk"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/refbrain/REF-1.nrrd"


#COPY OVER REFERENCE BRAIN 
cp $REGDIR/MakeAverageBrain-master/refbrain/*symmetric* $REGDIR/channel_registration/refbrain/REF-1.nrrd

#GET NUM SLICES
"$IJ" --headless -macro "$REGDIR/analysis/get_slices.ijm"

#split channels and save all as nrrd, save nc82 channels as tif
echo "------------SPLITTING STACKS-------------"
$IJ --headless -macro "$REGDIR/analysis/split_master.ijm"

while IFS='' read -r line || [[ -n "$line" ]]; do
    slices+=($line)
done < "$REGDIR/analysis/slices.txt"


for dir in $IMDIR/*; 
do
    i=true
    slice_index=0
    fixed_filepath=0
    slices_25=0
    for file in $dir/*40C1-.tif*; 
    do 
        other_channels+=($file)
    done
    for file in $dir/*40C3-.tif*;
    do
        other_channels+=($file)
    done
    for file in $dir/*C2-.tif;
    do
        echo $i
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
        python $REGDIR/analysis/high_low_reg/zstack2zstack_registration.py $slices_25 $slices_40 $fixed_filepath $moving_filepath $dir "xformed" $other_channels
done
echo "----------DONE WITH HIGH TO LOW RES REGISTRATION----------------"

echo "------------GENERATING INITIAL 25x nc82 REGISTRATIONS------------"
#move 25x nrrd files to registration images folder
cd $IMDIR
for dir in "$IMDIR/*";
do
    mv $dir/*25_01.nrrd "$REGDIR/channel_registration/images"
done

#GENERATE INITIAL AFFINE AND WARP REGISTRATIONS FOR ALL BRAINS
cd $REGDIR/channel_registration

"/home/emily/Fiji.app/bin/cmtk/munger" -b "/home/emily/Fiji.app/bin/cmtk" -a -w -r 01  -X 26 -C 8 -G 80 -R 4 -A '--accuracy 0.4' -W '--accuracy 0.4'  -T 8 -s "refbrain/REF-1.nrrd" images


echo "-------------------DONE WITH INITIAL REGISTRATION-------------------"

echo "----------------REFORMATTING OTHER 40x CHANNELS---------------------"

#TRANSFORM 40x CHANNELS W 25x AFFINE & WARP REGISTRATIONS

for file in /home/emily/registration/channel_registration/Registration/affine/*; do
    affine+=($file)
done 

for file in /home/emily/registration/channel_registration/Registration/warp/*; do
    warp+=($file)
done 
#$1 = affine or warp

function reformat() {
    i=0
    for dir in $IMDIR/*; do 
        for image in $dir/transforms/*.nrrd; do 
            if [ "$1" = "affine" ]
            then
            "$CMTKDIR/reformatx" -o "$image" --floating "$image" "$REFBRAIN" "${affine[$i]}" 
            else
            "$CMTKDIR/reformatx" -o "$image" --floating "$image" "$REFBRAIN" "${warp[$i]}"
            fi
        done
        i=$(($i + 1))
    done
}

reformat "affine"
reformat "warp"





