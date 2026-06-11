// measure_tissue_area.ijm
// -------------------------------------------------------------------
// Batch-measures TISSUE AREA for every .tif in a folder (and subfolders),
// for use as the denominator in plaque-burden calculations.
//
// Strategy:
//   1. Convert to grayscale.
//   2. Threshold tissue vs white background (tissue is darker than the
//      bright/white slide background).
//   3. Remove small debris with Analyze Particles (size filter), fill holes.
//   4. Sum the area of all retained tissue regions per image.
//   5. Write tissue_areas.csv : filename, tissue_area_um2, tissue_area_mm2
//
// HOW TO RUN:
//   Fiji > Plugins > Macros > Run...  (select this file)
//   It will prompt for the input folder and parameters.
//
// IMPORTANT: tune MIN_TISSUE_PARTICLE_UM2 if debris is being counted
//   (raise it) or if real tissue is being dropped (lower it).
// -------------------------------------------------------------------

// -------- USER PARAMETERS (prompted) --------
#@ File   (label="Folder of raw .tif sections", style="directory") inputDir
#@ Double (label="Microns per pixel", value=1.55) UM_PER_PIXEL
#@ Double (label="Min tissue particle size to keep (um^2)", value=100000) MIN_TISSUE_PARTICLE_UM2
#@ String (label="Output CSV name", value="tissue_areas.csv") outName

// -------- setup --------
setBatchMode(true);
umPerPx2 = UM_PER_PIXEL * UM_PER_PIXEL;       // um^2 per pixel
minPx = MIN_TISSUE_PARTICLE_UM2 / umPerPx2;   // min particle size in pixels

// gather files recursively
list = getFileTree(inputDir);

// CSV header
out = "filename,tissue_area_px,tissue_area_um2,tissue_area_mm2\n";

for (i = 0; i < list.length; i++) {
    path = list[i];
    if (!endsWith(toLowerCase(path), ".tif") && !endsWith(toLowerCase(path), ".tiff")) continue;

    open(path);
    title = getTitle();

    // grayscale
    if (bitDepth() == 24) run("8-bit");

    // set scale so measurements come out in calibrated units if desired
    // (we compute area ourselves from pixel counts to stay explicit)
    run("Set Scale...", "distance=1 known=" + UM_PER_PIXEL + " unit=um");

    // threshold: tissue darker than bright background.
    // Default method = Otsu; dark objects on light background.
    setAutoThreshold("Otsu dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // clean up: fill interior holes (ventricles/folia gaps inside tissue
    // would otherwise be subtracted; comment out if you want them excluded)
    run("Fill Holes");

    // measure tissue area via Analyze Particles with a size floor that
    // drops debris specks but keeps real tissue pieces.
    run("Set Measurements...", "area redirect=None decimal=3");
    run("Clear Results");
    run("Analyze Particles...", "size=" + minPx + "-Infinity pixel show=Nothing clear summarize");

    // Analyze Particles "summarize" puts total area in the Summary window;
    // but to keep it simple and robust we sum the Results areas (in px since
    // we asked in pixel units via 'pixel' flag).
    totalPx = 0;
    n = nResults;
    for (r = 0; r < n; r++) {
        totalPx += getResult("Area", r);
    }

    area_um2 = totalPx * umPerPx2;
    area_mm2 = area_um2 / 1e6;

    out += title + "," + totalPx + "," + area_um2 + "," + area_mm2 + "\n";

    close("*");
}

// write CSV next to input folder
outPath = inputDir + File.separator + outName;
File.saveString(out, outPath);
setBatchMode(false);
print("Done. Wrote: " + outPath);

// -------- helper: recursive file listing --------
function getFileTree(dir) {
    files = newArray(0);
    raw = getFileList(dir);
    for (j = 0; j < raw.length; j++) {
        p = dir + File.separator + raw[j];
        if (File.isDirectory(p)) {
            sub = getFileTree(p);
            files = Array.concat(files, sub);
        } else {
            files = Array.concat(files, p);
        }
    }
    return files;
}
