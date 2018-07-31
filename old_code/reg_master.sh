#!/bin/sh
#20170726
#emily

CMTKDIR="/home/emily/cmtk"
REGDIR="/home/emily/registration"
CHANNELDIR="$REGDIR/channels/"
REFCHANDIR="$REGDIR/reformatted_channels"
REFBRAIN="/home/emily/MakeAverageBrain-master/reformatted/whatever the average brain is called.nrrd"
STACKDIR="/home/emily/registration/images"
IJDIR="/home/emily/Fiji.app"

#extract nc82 channels from 25x and 40x and save as tif
echo "------------SPLITTING STACKS-------------"
$IJDIR/ImageJ-linux64 --headless -macro "$REGDIR/split_master.ijm"


#align and reslice higher res stack to lower res stack'
echo "--------STARTING HIGH TO LOW RES REGISTRATION-------------------"
stak2stak_reg () {
    python $REGDIR/high_low_reg/zstack2zstack_registration.py $1 $2 $3 $4 $5 $6
}

for dir in $STACKDIR/*; 
do
    i=0
    j=0
    k=1
    for file in $dir/*-.tif;
    do
        if [ $i -eq $j ]
        then
        #NOT RETURNING NUMBER OF SLICES. FIX LATER
        slices_25=$($IJDIR/ImageJ-linux64 --headless -macro "$REGDIR/nSlices.ijm" $file)
        fixed_filepath="$file"
        i=$(($i + 1))
        elif [ $i -eq $k ]
        then 
        slices_40=$("$IJDIR/ImageJ-linux64" --headless -macro "$REGDIR/nSlices.ijm" $file)
        moving_filepath="$file"
        i=$(($i - 1))
        fi
        stak2stak_reg 203 195 $fixed_filepath $moving_filepath $dir "transformedthing"
        
    done
done
echo "----------DONE WITH HIGH TO LOW RES REGISTRATION----------------"


echo "------------GENERATING INITIAL 25x nc82 REGISTRATIONS------------"
#move 25x nrrd files to registration images folder
cd $REGDIR/images
for dir in $REGDIR/images;
do
    mv ./$dir/*_25.tifC2-.tif "$REGDIR/channel_registration/images"
done
$IJDIR/ImageJ-linux64 --headless -macro "$REGDIR/channel_registration/commands/LSKLJERLJHER"


#GENERATE INITIAL AFFINE AND WARP REGISTRATIONS FOR ALL BRAINS
cd $REGDIR
#"$CMTKDIR/build/bin/munger" -b "$CMTKDIR" -a -w -r 01 -T 2 -s "$REFBRAIN" images

echo "-------------------DONE WITH INITIAL REGISTRATION-------------------"
#make affine and warp reformatted directories for each brain & run reformatx
#cd "$CHANNELDIR"
#for dir in */; do
#    mkdir "$REFCHANDIR/$dir/affine"
#    mkdir "$REFCHANDIR/$dir/warp"
#    NUM=1;
#   for im in $dir; do 
#        "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir/affine" --floating "$CHANNELDIR/$dir/$im" "$REFBRAIN" "$EMREGDIR/Registration/affine/$NUM OR WHATEVER IT;s called_affine thing.list" 

#        "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir/warp" --floating "$REFCHANDIR/$dir/affine/$NUM FIND OUT HOW THIS GETS NAMED" "$REFBRAIN" "$EMREGDIR/Registration/warp/$NUM WHAT IS THIS CALLED warp.list"





