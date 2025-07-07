macro "PseduoSoma with Rolling Ball Subtraction" {
    // Step 1: Select input folder
    inputDir = getDirectory("Select a folder containing stacked TIF images");
    if (inputDir == "") exit("No input folder selected!");

    // Step 2: Select output folder
    outputDir = getDirectory("Select a folder to save processed images");
    if (outputDir == "") exit("No output folder selected!");

    // Get processing parameters
    ballRadius = getNumber("Rolling ball radius for background subtraction:", 50);
    claheBlockSize = getNumber("CLAHE block size:", 127);
    claheMax = getNumber("CLAHE maximum slope (1-6):", 2);

    // Get list of TIF/TIFF files
    list = getFileList(inputDir);
    totalFiles = 0;

    // Count only TIF/TIFF files
    for (i = 0; i < list.length; i++) {
        if (endsWith(toLowerCase(list[i]), ".tif") || endsWith(toLowerCase(list[i]), ".tiff")) {
            totalFiles++;
        }
    }

    fileCount = 0;

    for (i = 0; i < list.length; i++) {
        if (endsWith(toLowerCase(list[i]), ".tif") || endsWith(toLowerCase(list[i]), ".tiff")) {
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

            // MODIFIED STEP: Rolling Ball Background Subtraction (replaces Gaussian subtraction)
            run("Subtract Background...", "rolling=" + ballRadius + " sliding");

            // Step 5: CLAHE Intensity Normalization (with configurable block size)
            run("Enhance Local Contrast (CLAHE)", "blocksize=" + claheBlockSize + " histogram=256 maximum=" + claheMax);

            // Step 6: Global Intensity Normalization
            run("32-bit"); 
            getStatistics(area, mean, min, max, stdDev);
            if (max > 0) {
                run("Multiply...", "value=" + (255.0 / max));
                run("Enhance Contrast", "saturated=0 stretch");
                run("8-bit");
            }
            rename("Final_Image");

            // Step 7: Save Final Image in Output Folder
            saveName = replace(list[i], ".tif", "_processed.tif");
            saveName = replace(saveName, ".tiff", "_processed.tif");
            saveName = replace(saveName, ".TIF", "_processed.tif");
            saveName = replace(saveName, ".TIFF", "_processed.tif");
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

    print("=== Processing Complete ===");
    print(totalFiles + " images processed with parameters:");
    print("- Rolling ball radius: " + ballRadius);
    print("- CLAHE block size: " + claheBlockSize);
    print("- CLAHE max slope: " + claheMax);
    print("Saved to: " + outputDir);
}