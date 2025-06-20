
![ImageJ](https://img.shields.io/badge/ImageJ-Macro-blue)
![Status](https://img.shields.io/badge/status-Prototype--Stable-yellow)

# MagiCAL

**MagiCAL** (*Multimodal Automated Intensity-normalized Contrast-Adjusted Local-enhancement*) is an **ImageJ macro-based pipeline** designed to standardize preprocessing of fluorescent microscopy images. It ensures reproducibility and visual consistency across imaging batches, users, and modalities by automating background subtraction, contrast enhancement, and intensity normalization.

This tool is ideal for labs working with:
- Fluorescent imaging data
- Multi-user imaging datasets
- Cross-condition image comparison
- High-throughput preprocessing

---

## ✨ Key Features

- Batch processing of `.tiff` image stacks
- 16-bit to 8-bit image conversion with scaling
- CLAHE (local contrast enhancement)
- Gaussian background subtraction
- Global intensity normalization
- Auto contrast and brightness stretching
- Structured file saving with suffix tagging
- Fully automated – no manual tuning needed

---

## 📁 Input Requirements

Place your `.tiff` images in a folder. Each image should be a stacked TIFF (single or multi-slice).

**Example Folder Structure:**
```plaintext
YourInputFolder/
├── sample1.tiff
├── sample2.tiff
└── ...
```

---

## 🖼️ Output

Processed images are saved in the **a separate output folder** with a `_processed.tif` suffix.

```plaintext
YourInputFolder/
├── sample1_processed.tif
├── sample2_processed.tif
└── ...
```

---

## 🔁 Processing Steps

For each image, **MagiCAL** performs the following sequence:

1. **Load Image**
2. **Convert to 16-bit**
3. **Enhance Global Brightness & Contrast**
4. **Apply Gaussian Blur (σ = 7) to Background**
5. **Subtract Blurred Background**
6. **Apply CLAHE for Local Enhancement**
7. **Normalize Intensities to 0–255 Range**
8. **Convert to 8-bit**
9. **Save as `_processed.tif`**
10. **Clean up intermediate images**

---

##  Example Use Cases

- Imaging core facilities standardizing data from multiple users
- Preprocessing GFP-expressing brain slices before quantification
- Comparing intensity across sessions or devices
- Automated quality control pipelines

---

##  How to Use

1. **Open Fiji (ImageJ)**
   - Download from: https://imagej.net/software/fiji

2. **Run the Macro**
   - `Plugins > Macros > Run...`
   - Select the file: `MagiCAL.ijm`

3. **Select Input Folder**
   - Choose the folder containing your `.tiff` images when prompted
  
4. **Select Output Folder**
   - Choose the folder in which the processed `.tiff` images are to be saved

5. **Wait for Processing**
   - The script will process all images and save results automatically

---

##  Requirements

- Fiji / ImageJ with macro support (tested on Fiji 2.14.0)
- Images in `.tiff` format
- Optional: Sufficient RAM for large image stacks

---

##  Repository Structure

```plaintext
MagiCAL/
├── MagiCAL.ijm                # ImageJ macro script
├── README.md                  # Project documentation
├── .gitignore                 # Ignore temp/image files
├── sample_images/             # (Optional) Sample test images
└── processed_outputs/         # (Optional) Example outputs
```

---

##  Future Features (Planned)

- Multi-channel image compatibility
- GUI for parameter tuning (sigma, CLAHE block size, etc.)
- Optional output folder selection
- Logging system for tracking batch runs

---

##  Author

**Vatsal D. Jariwala**  
NeuroEngineering Laboratory, 
Department of Neurosurgery,  
University Hospital Freiburg, Germany

---

##  License

This project is licensed under the **MIT License**.  
See the `LICENSE` file for full terms.

---

##  Acknowledgements

- Developed in the context of reproducible single-cell imaging workflows.
- Built using [Fiji/ImageJ](https://imagej.net/) – a powerful tool for bioimage analysis.

---

##  Citation

If you use MagiCAL in your work, please cite the GitHub repository or mention:

**Vatsal D. Jariwala, MagiCAL (2025), University Hospital Freiburg.**  
*A preprocessing pipeline for standardized fluorescent image normalization.*  

---

##  Feedback & Contributions

We welcome suggestions and contributions.  
Feel free to open an issue or submit a pull request!
