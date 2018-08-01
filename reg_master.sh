#!/bin/bash
#20170726
#emily

CMTKDIR="/home/emily/cmtk"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/refbrain/REF-1.nrrd"


#COPY OVER REFERENCE BRAIN 
#cp $REGDIR/MakeAverageBrain-master/refbrain/*symmetric* $REGDIR/channel_registration/refbrain/REF-1.nrrd

#GET NUM SLICES
"$IJ" --headless -macro "$REGDIR/analysis/get_slices.ijm"

#split channels and save all as nrrd, save nc82 channels as tif
echo "------------SPLITTING STACKS-------------"
$IJ --headless -macro "$REGDIR/analysis/split_master.ijm"

#START COMMENT
if false
then
#align and reslice higher res stack to lower res stack
echo "--------STARTING HIGH TO LOW RES REGISTRATION-------------------"
stak2stak_reg () {
    python $REGDIR/analysis/high_low_reg/zstack2zstack_registration.py $1 $2 $3 $4 $5 $6
}

while IFS='' read -r line || [[ -n "$line" ]]; do
    slices+=($line)
done < "$REGDIR/slices.txt"


for dir in $IMDIR/*; 
do
    i=true
    slice_index=0
    fixed_filepath=0
    slices_25=0
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
        stak2stak_reg $slices_25 $slices_40 $fixed_filepath $moving_filepath $dir "xformed"
done

echo "----------DONE WITH HIGH TO LOW RES REGISTRATION----------------"
#END COMMENT
fi

echo "------------GENERATING INITIAL 25x nc82 REGISTRATIONS------------"
#move 25x nrrd files to registration images folder
cd $IMDIR
for dir in $IMDIR;
do
    mv ./$dir/*25_01.nrrd "$REGDIR/channel_registration/images"
done

#GENERATE INITIAL AFFINE AND WARP REGISTRATIONS FOR ALL BRAINS
cd $REGDIR/channel_registration

"/home/emily/Fiji.app/bin/cmtk/munger" -b "/home/emily/Fiji.app/bin/cmtk" -a -w -r 01  -X 26 -C 8 -G 80 -R 4 -A '--accuracy 0.4' -W '--accuracy 0.4'  -T 8 -s "ref_brain/REF-1.nrrd" images


echo "-------------------DONE WITH INITIAL REGISTRATION-------------------"
#START COMMENT
if false 
then
echo "----------------REFORMATTING OTHER 40x CHANNELS---------------------"

#TRANSFORM 40x CHANNELS INTO 25x IMAGE SPACE 
for dir in "$REGDIR/images"; do
    cd $dir
    reformat C1 and C3 40x from "./" with stuff from "./transforms/xformed"
    save to "./transforms"
done

#TRANSFORM 40x CHANNELS W 25x AFFINE & WARP REGISTRATIONS

cd "/home/emily/registration/channel_registration/Registration/affine"
affine=getFileList()

cd "/home/emily/registration/channel_registration/Registration/warp"
warp=getFileList()

#$1 = affine or warp

function reformat() {
    i=0
    for dir in "$REGDIR/images"; do
        cd $dir
        for image in $dir; do 
            if ["$1" = "affine"]
            then
            "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir" --floating "$CHANNELDIR/$dir/$im" "$REFBRAIN" "$REGDIR/Registration/affine/affine[i]" 
            else
            "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir/warp" --floating "$REFCHANDIR/$dir/affine/$NUM FIND OUT HOW THIS GETS NAMED" "$REFBRAIN" "$EMREGDIR/Registration/warp/warp[i]"
            fi
        done
        $i=$(($1 + 1))
    done
}

reformat "affine"
reformat "warp"

fi




