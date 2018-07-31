#!/bin/sh
#meow
#  ^_^
# (o_0)  _/
# /v v\_/ 
# \m_m/


CMTKDIR="/home/emily/cmtk"
REGDIR="/home/emily/template_brain/registration"
CHANNELDIR="$EMREGDIR/channels/"
REFCHANDIR="$EMREGDIR/reformatted_channels"
REFBRAIN="/home/emily/MakeAverageBrain-master/reformatted/whatever the average brain is called.nrrd"

#SPLIT CHANNELS 

#figure out macro plugin

./ImageJ-linux64 --ij2 --headless --run split.py


#GENERATE INITIAL AFFINE AND WARP REGISTRATIONS FOR ALL BRAINS

cd $REGDIR
"$CMTKDIR/build/bin/munger" -b "$CMTKDIR" -a -w -r 01 -T 2 -s "$REFBRAIN" images


#make affine and warp reformatted directories for each brain & run reformatx
cd "$CHANNELDIR"
for dir in */; do
    mkdir "$REFCHANDIR/$dir/affine"
    mkdir "$REFCHANDIR/$dir/warp"
    NUM=1;
    for im in $dir; do 
        "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir/affine" --floating "$CHANNELDIR/$dir/$im" "$REFBRAIN" "$EMREGDIR/Registration/affine/$NUM OR WHATEVER IT;s called_affine thing.list" 

        "$CMTKDIR/reformatx" -o OUT "$REFCHANDIR/$dir/warp" --floating "$REFCHANDIR/$dir/affine/$NUM FIND OUT HOW THIS GETS NAMED" "$REFBRAIN" "$EMREGDIR/Registration/warp/$NUM WHAT IS THIS CALLED warp.list"





