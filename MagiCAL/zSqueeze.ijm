macro "zSqueeze" {
    // Select input folder
    inputDir = getDirectory("Choose folder containing Z-stacks");
    if (inputDir == "") exit("No folder selected");
    
    // Select output folder
    outputDir = getDirectory("Choose output folder");
    if (outputDir == "") exit("No output folder selected");
    
    // Get processing parameters
    ballRadius = getNumber("Rolling ball radius:", 50);
    
    // Process all TIFF files
    list = getFileList(inputDir);
    setBatchMode(true);
    
    for (i = 0; i < list.length; i++) {
        filename = list[i];
        if (endsWith(toLowerCase(filename), ".tif") || endsWith(toLowerCase(filename), ".tiff")) {
            
            // Open stack
            open(inputDir + filename);
            originalTitle = getTitle();
            
            // Convert stack to individual images
            run("Stack to Images");
            
            // Get list of slice images
            sliceNames = newArray(nImages);
            for (s = 0; s < nImages; s++) {
                selectImage(s+1);
                sliceNames[s] = getTitle();
            }
            
            // Process each slice with rolling ball subtraction
            for (s = 0; s < sliceNames.length; s++) {
                selectWindow(sliceNames[s]);
                run("Subtract Background...", "rolling=" + ballRadius + " sliding");
                print("Processed slice: " + sliceNames[s]);
            }
            
            // Recombine into stack
            run("Images to Stack", "name=Processed_Stack title=[] use");
            processedStack = getTitle();
            
            // Create Z-projection (sum slices)
            run("Z Project...", "projection=[Sum Slices]");
            projTitle = getTitle();
            
            // Save results
            baseName = replace(filename, ".tif", "");
            baseName = replace(baseName, ".tiff", "");
            saveAs("Tiff", outputDir + baseName + "_RBsub_proj.tif");
            
            // Clean up
            close(projTitle);
            close(processedStack);
            for (s = 0; s < sliceNames.length; s++) {
                close(sliceNames[s]);
            }
            close(originalTitle);
            
            print("Completed: " + filename);
        }
    }
    
    setBatchMode(false);
    print("All stacks processed successfully!");
}