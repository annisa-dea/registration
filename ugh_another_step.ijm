
setBatchMode(true);
image_folders=getFileList("/home/emily/registration/images_1");
print(image_folders.length);
for(i=0; i<image_folders.length; i++) {
    images=getFileList("/home/emily/registration/images_1/" + image_folders[i] + "transforms");
    for(j=0; j<images.length; j++){
        if (indexOf(images[j], "0.tif")>=0){
            print(image_folders[i]);
            print(images[j]);
            open("/home/emily/registration/images_1/" + image_folders[i] + "transforms/" + images[j]);
            slice=nSlices;
            run("Properties...", "channels=1 slices=" + slice + " frames=1 unit=micron pixel_width=0.6060606 pixel_height=0.6060606 voxel_depth=1");
            run("8-bit");
            run("Nrrd ... ", "nrrd="+ "/home/emily/registration/images_1/" + image_folders[i] + "transforms/" + images[j] + ".nrrd");
    }
}

