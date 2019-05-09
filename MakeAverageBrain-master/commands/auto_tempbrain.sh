#! /bin/sh
#split channels, save nc82 as nrrd, run MakeAverageBrain (Jefferis lab)

#Fiji Application location
IJDIR="/home/emily/Fiji.app/ImageJ-linux64"

#Directory where you set up folders for template brains
AVGBRAINDIR="/home/emily/registration/MakeAverageBrain-master"


REFBRAIN="REF"
NUM_ITERATIONS=5 


#save stack tif files onto /images/stacks, no naming convention
#splits channels, saves second channel as nrrd for all stacks into /images
#in this case, second channel is nc82. Adjust channel in split.iijm file if nc82 in different channel
$IJDIR --headless -macro /home/emily/registration/MakeAverageBrain-master/commands/split.ijm

#move first image to refbrain
#first brain needed for temporary first pass template
mv "$AVGBRAINDIR/images/0_01.nrrd" "$AVGBRAINDIR/refbrain"
mv "$AVGBRAINDIR/refbrain/0_01.nrrd" "$AVGBRAINDIR/refbrain/$REFBRAIN-1.nrrd"

#run MakeAverageBrain

cd "$AVGBRAINDIR"
./commands/makeAverageBrain-sync.sh $REFBRAIN- $NUM_ITERATIONS 
