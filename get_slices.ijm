
file = File.open("/home/lab/random_code/slices.txt");
//file=File.open("/home/emily/registration/analysis/slices.txt");

setBatchMode(true);
print("starting");
input="/home/lab/registration/images/";
output="/home/lab/registration/images/";
dir_list = getFileList(input);

for (i=0; i<dir_list.length; i++) {
    file_list = getFileList(input+dir_list[i]);
    for (j=0; j<file_list.length; j++) {
        if (indexOf(file_list[j], "_25.tifC2-.tif")>=0) {
            open(input+dir_list[i]+file_list[j]);
	    print(file, nSlices);
            }
	}
    }

