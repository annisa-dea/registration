/*
macro plugin for ImageJ to split channels and save second channel as nrrd file
20180725
emily
*/

function split_save(input, output, filename) {
    open(input + filename);
    run("Split Channels");
    selectWindow("C2-" + filename);
    run("Nrrd ... ", "nrrd=" + output + i + "_01.nrrd");
    close();
   }

print("starting");

input = "/home/emily/registration/MakeAverageBrain-master/images/stacks/";
output = "/home/emily/registration/MakeAverageBrain-master/images/";

setBatchMode(true);

list = getFileList(input);
for (i = 0; i < list.length; i++) {
    split_save(input, output, list[i]);
    }
print("ending");

setBatchMode(false);
