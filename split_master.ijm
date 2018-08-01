//20180728
//emily 

function save_nrrd(channels, output, filename) {
    for (i=0; i < channels.length; i++){
        selectWindow(channels[i] + filename);
        run("Nrrd ... ", "nrrd=" + output + channels[i] + substring(filename, 0, 4) + "_01.nrrd");
    }
    
}

function save_tif(channels, output, filename) {
    for (i=0; i<channels.length; i++){
        selectWindow(channels[i] + filename);
        saveAs("Tiff", output + substring(filename,0,4) + channels[i] + ".tif");

    }
}

function split_save(input, output, filename, low_res, row) {
    open(input + filename);
    run("Split Channels");
    if(low_res) {
        channels = newArray("C2-");
    }
    else {
        channels = row;
    }

    save_nrrd(channels, output, filename);
    channel=newArray("C2-");
    save_tif(channel, output, filename);
    close();
    
}

//MAKE SURE CHANNELS.TXT DOESN'T END WITH BLANK LINE
channels_doc=File.openAsString("/home/emily/registration/analysis/channels.txt");
channel_row=split(channels_doc, "\n");
//for(i=0; i<channel_row.length; i++){
 //   row=split(channel_row[i]);
//    print(row[0]);
//}

print("starting");
//path must end with backslash
input = "/home/emily/registration/images/";
output = "/home/emily/registration/images/";

setBatchMode(true);

dir = getFileList(input);

for (i = 0; i < dir.length; i++) {
    files = getFileList(input + dir[i]);
    row=split(channel_row[i]);
    for (j = 0; j<files.length; j++){
        low_res=false;
        if(indexOf(files[j], "_25.tif")>=0) {
            low_res=true;
        }
        split_save(input+dir[i], input+dir[i], files[j], low_res, row);
    }
}
print("ending");

