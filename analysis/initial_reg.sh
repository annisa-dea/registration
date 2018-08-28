#!/bin/bash

CMTKDIR="/home/emily/cmtk/build/bin"
REGDIR="/home/emily/registration"
IMDIR="/home/emily/registration/images_1"
IJ="/home/emily/Fiji.app/ImageJ-linux64"
REFBRAIN="/home/emily/registration/channel_registration/refbrain/REF-1.nrrd"

"$IJ" --headless -macro "$REGDIR/analysis/get_slices.ijm"

#split channels and save all as nrrd, save nc82 channels as tif
echo "------------SPLITTING STACKS-------------"
$IJ --headless -macro "$REGDIR/analysis/split_master.ijm"

#move 25x nrrd files to registration images folder
cd $IMDIR
for dir in "$IMDIR/*";
do
    mv $dir/*25_01.nrrd "$REGDIR/channel_registration/images"
done

#GENERATE INITIAL AFFINE AND WARP REGISTRATIONS FOR ALL BRAINS
cd $REGDIR/channel_registration

"/home/emily/Fiji.app/bin/cmtk/munger" -b "/home/emily/Fiji.app/bin/cmtk" -a -w -r 01  -X 26 -C 8 -G 80 -R 4 -A '--accuracy 0.4' -W '--accuracy 0.4'  -T 8 -s "refbrain/REF-1.nrrd" images


