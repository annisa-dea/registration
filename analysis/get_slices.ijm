
file=File.open("/home/emily/registration/analysis/slices.txt");

setBatchMode(true);

print("start");
input="/home/emily/registration/images/";
dir_list = getFileList(input);

for (i=0; i<dir_list.length; i++) {
    file_list = getFileList(input+dir_list[i]);
    for (j=0; j<file_list.length; j++) {
        open(input+dir_list[i]+file_list[j]);
        print(file,nSlices);
	}
    }
print("end");
