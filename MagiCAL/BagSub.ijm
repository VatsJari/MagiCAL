macro "BagSub" {
    // Step 1: Select input and output folders
    inputDir = getDirectory("Select a folder containing TIF images");
    if (inputDir == "") exit("No input folder selected!");

    outputDir = getDirectory("Select a folder to save processed images");
    if (outputDir == "") exit("No output folder selected!");

    // Step 2: Get processing parameters once at the beginning
    unsharpRadius = getNumber("Unsharp Mask radius:", 2);
    unsharpMask = getNumber("Unsharp Mask amount (0-1):", 0.80);
    claheBlocksize = getNumber("CLAHE block size:", 127);
    claheMax = getNumber("CLAHE maximum slope:", 3);
    rollingBall = getNumber("Background subtraction rolling ball radius:", 50);

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

            open(inputDir + fileName);
            originalImage = getTitle();
            print("Processing: " + originalImage);

            // Convert to 16-bit
            run("16-bit");
            
            // Sharpen structures with custom parameters
            run("Unsharp Mask...", "radius=" + unsharpRadius + " mask=" + unsharpMask);
 
            // CLAHE for adaptive contrast enhancement with custom parameters
            run("Enhance Local Contrast (CLAHE)", "blocksize=" + claheBlocksize + " histogram=256 maximum=" + claheMax + " mask=*None*");

            // Background Subtraction with custom rolling ball radius
            run("Subtract Background...", "rolling=" + rollingBall + " disable");

            // Auto Brightness (Enhance Contrast, full stretch)
            run("Enhance Contrast", "saturated=0 stretch");

            // Save processed image (case insensitive replacement)
            saveName = fileName;
            if (endsWith(lowerFileName, ".tiff")) {
                saveName = replace(saveName, ".tiff", "_Processed.tif");
                saveName = replace(saveName, ".TIFF", "_Processed.tif");
            } else {
                saveName = replace(saveName, ".tif", "_Processed.tif");
                saveName = replace(saveName, ".TIF", "_Processed.tif");
            }
            savePath = outputDir + saveName;
            saveAs("Tiff", savePath);
            print("Saved: " + savePath);

            // Cleanup
            close();

            fileCount++;
            progress = round((fileCount / totalFiles) * 100);
            print("Progress: " + fileCount + "/" + totalFiles + " (" + progress + "%)");
        }
    }

    print("Batch processing complete! Files saved to: " + outputDir);
}