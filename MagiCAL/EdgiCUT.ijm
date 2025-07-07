macro "Trim Tissue Edges with Minimum Auto Thresholding" {
    // Step 1: Select input folder
    inputDir = getDirectory("Select a folder containing stacked TIF images");
    if (inputDir == "") exit("No input folder selected!");

    // Step 2: Select output folder
    outputDir = getDirectory("Select a folder to save processed images");
    if (outputDir == "") exit("No output folder selected!");

    // Step 3: Get parameters once at the beginning
    sigmaValue = getNumber("Enter Gaussian Blur sigma value:", 50);
    expandPixels = getNumber("Shrink mask inward by how many pixels?", 100);

    // Get list of TIF/TIFF files (case insensitive)
    list = getFileList(inputDir);
    totalFiles = 0;

    for (i = 0; i < list.length; i++) {
        fileName = list[i];
        lowerFileName = toLowerCase(fileName);
        if (endsWith(lowerFileName, ".tif") || endsWith(lowerFileName, ".tiff")) {
            totalFiles++;
        }
    }

    fileCount = 0;

    for (i = 0; i < list.length; i++) {
        fileName = list[i];
        lowerFileName = toLowerCase(fileName);
        if (endsWith(lowerFileName, ".tif") || endsWith(lowerFileName, ".tiff")) {
            // Close all open images
            while (nImages > 0) {
                selectImage(nImages);
                close();
            }

            // Open and convert original to 16-bit
            open(inputDir + fileName);
            originalTitle = getTitle();
            print("Opened: " + originalTitle);
            run("16-bit");

            // Duplicate for processing
            run("Duplicate...", "title=Processing");
            selectWindow("Processing");

            // Enhance contrast multiple times
            run("Enhance Contrast", "saturated=5");
   
            // Apply LUT to lock contrast
            run("Apply LUT");

            // Apply Gaussian Blur with user-defined sigma
            run("Gaussian Blur...", "sigma=" + sigmaValue);

            // Auto thresholding (Minimum dark)
            setAutoThreshold("Minimum dark");
            setOption("BlackBackground", true);
            run("Convert to Mask");

            // Erode to shrink mask using user-defined pixels
            for (j = 0; j < expandPixels; j++) {
                run("Erode");
            }

            // Create selection from mask
            run("Create Selection");

            // Apply selection to original image
            selectWindow(originalTitle);
            run("Duplicate...", "title=Trimmed_Image");
            selectWindow("Trimmed_Image");
            run("Restore Selection");
            run("Clear Outside"); // This keeps only tissue, removes outer background

            // Remove selection outline before saving
            run("Select None");

            // Save image (case insensitive replacement)
            saveName = fileName;
            if (endsWith(lowerFileName, ".tiff")) {
                saveName = replace(saveName, ".tiff", "_Trimmed.tif");
                saveName = replace(saveName, ".TIFF", "_Trimmed.tif");
            } else {
                saveName = replace(saveName, ".tif", "_Trimmed.tif");
                saveName = replace(saveName, ".TIF", "_Trimmed.tif");
            }
            saveAs("Tiff", outputDir + saveName);
            print("Saved: " + outputDir + saveName);

            fileCount++;
            print("Progress: " + fileCount + "/" + totalFiles);
        }
    }

    print("✅ All images processed and saved to: " + outputDir);
}