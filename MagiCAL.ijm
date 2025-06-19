macro "Preprocess Image and Save Final Version" {
    // Step 1: Select input folder
    inputDir = getDirectory("Select a folder containing stacked TIF images");
    if (inputDir == "") exit("No input folder selected!");

    // Step 2: Select output folder
    outputDir = getDirectory("Select a folder to save processed images");
    if (outputDir == "") exit("No output folder selected!");

    // Get list of TIF/TIFF files
    list = getFileList(inputDir);
    totalFiles = 0;

    // Count only TIF/TIFF files
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
            totalFiles++;
        }
    }

    fileCount = 0;

    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
            // Close all open images before processing the next one
            while (nImages > 0) {
                selectImage(nImages);
                close();
            }

            open(inputDir + list[i]);
            originalImage = getTitle();
            print("Opened Image: " + originalImage);

            // Step 1: Convert to 16-bit
            run("16-bit");

            // Step 2: Auto Brightness Adjustment
            run("Enhance Contrast", "saturated=0 stretch");

            // Step 3: Contrast Enhancement
            run("Enhance Contrast", "saturated=0.1 normalize");

            // Step 4: Gaussian Background Subtraction
            run("Duplicate...", "title=Gaussian_Background");
            selectWindow("Gaussian_Background");
            run("Gaussian Blur...", "sigma=10");
            imageCalculator("Subtract create", originalImage, "Gaussian_Background");
            close("Gaussian_Background");

            selectWindow("Result of " + originalImage);
            rename("Background_Subtracted");

            // Step 5: CLAHE Intensity Normalization
            run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=2");

            // Step 6: Global Intensity Normalization
            run("32-bit"); 
            getStatistics(area, mean, min, max, stdDev);
            if (max > 0) {
                run("Multiply...", "value=" + 255.0 / max);
                run("Enhance Contrast", "saturated=0 stretch");
                run("8-bit");
            }
            rename("Final_Image");

            // Step 7: Save Final Image in Output Folder
            saveName = replace(list[i], ".tif", "_processed.tif");
            saveName = replace(saveName, ".tiff", "_processed.tif");
            savePath = outputDir + saveName;
            saveAs("Tiff", savePath);
            print("Saved: " + savePath);

            // Close all images
            while (nImages > 0) {
                selectImage(nImages);
                close();
            }

            // Update progress
            fileCount++;
            progress = round((fileCount / totalFiles) * 100);
            print("Progress: " + fileCount + "/" + totalFiles + " (" + progress + "%)");
        }
    }

    print("All images processed and saved to: " + outputDir);
}
