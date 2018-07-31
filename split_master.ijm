//20180728
//emily 

function save_nrrd(channels, output, filename) {
    for (i=0; i < channels.length; i++){
        selectWindow(channels[i] + filename);
        run("Nrrd ... ", "nrrd=" + output + filename + channels[i] + "_01.nrrd");
    }
    
}

function save_tif(channels, output, filename) {
    for (i=0; i<channels.length; i++){
        selectWindow(channels[i] + filename);
        saveAs("Tiff", output + filename + channels[i] + ".tif");

    }
}

function split_save(input, output, filename, low_res) {
    open(input + filename);
    run("Split Channels");
    if(low_res) {
        channels = newArray("C2-");
    }
    else {
        channels = newArray("C1-", "C2-", "C3-");
    }

    save_nrrd(channels, output, filename);
    channel = newArray("C2-");
    save_tif(channel, output, filename);
    close();
    
}

print("starting");
input = "/home/emily/registration/images/";
output = "/home/emily/registration/images/";

setBatchMode(true);

dir = getFileList(input);

for (i = 0; i < dir.length; i++) {
    files = getFileList(input + dir[i]);
    for (j = 0; j<files.length; j++){
        low_res=false;
        if(indexOf(files[j], "_25.tif")>=0) {
            low_res=true;
        }
        split_save(input+dir[i], input+dir[i], files[j], low_res);
    }
}
print("ending");

