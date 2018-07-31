/*
20180726
emily
*/

function split_save(input, output, filename) {
    open(input + filename);
    run("Split Channels");
    selectWindow("C2-" + filename);
    saveAs("Tiff", output + j + "_01.tif");
    slices=nSlices;
    print(slices);
    return slices;
    close();
}

setBatchMode(true);
print("starting");
input="/home/emily/registration/images/";
output="/home/emily/registration/images/";
dir_list = getFileList(input);

for (i=0; i<dir_list.length; i++) {
    file_list = getFileList(input+dir_list[i]);
    for (j=0; j<file_list.length; j++) {
	split_save(input+dir_list[i], output+dir_list[i], file_list[j]);
	}
    }
print("ending");
setBatchMode(false);


