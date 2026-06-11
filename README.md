# Fuel_the_Build

## Pipeline designed for PrP Deposition Imaging Challenge

#### Team Leader: Alex Alon
#### Image Visaluzation and Automation Lead: Ryan Eastman
#### Data Manipulation and Visualization Leads: Marisa Foster and Danielle Samson

### Pipeline Approach: Snakemake

### Biological Question:
How does prion burden differ between elk and deer, and how does it differ based on region of the brain?


**Roadbloacks**
1. How do we distinguish between plaques and aggregates?
2. Determining the area of aggregates and plaques depends on how we quanitfy the area?
3. How do we get rid of background and account for false staining?
4. How do we normalize to WT?
5. Images have a certain dpi, so it may be hard to count aggregates in a cluster because it is blurry when we zoom in. How do we account for error?
6. Some aggregates are bold while some are faded based on where they are in the z field of the image. How do we account for different intensities of aggregates?

### Desired Outputs:
**Annotated Images Containing**
- Brain region
- Sample origin – deer, elk, or WT
- Sample ID #
- Magnification

#### Workflow

Prion plaque quantification pipeline (ilastik → CSV → burden)


#### What this does

PrP IHC sections (4x), brown DAB plaques on hematoxylin counterstain. Goal is plaque
burden per section = plaque area / tissue area, grouped by genotype (GtDeer / GtElk /
WT control) and region (cerebellum / hippocampus / midbrain / septum).

### The pipeline:

Pixel Classification (ilastik) -> train a plaque-vs-background classifier, then
batch-export a probability map (.h5) for every image.
Object Classification (ilastik) —> turn those probability maps into discrete plaque
objects, measure them, export one CSV per section.
Fiji macro —> measure tissue area per section (the denominator; ilastik never
measures this for you).
RStudio —> combine all the per-section CSVs and compute burden.

### Step 1 — Pixel Classification (make the probability maps)

ilastik → New Project → Pixel Classification.


Input Data -> add a handful of representative images spanning genotypes/regions to
train on (I used ~6). You do not train on all 686.

Feature Selection -> select features (the default sigmas are fine for this).

Training -> paint labels. Three classes: plaque / brain / background (or just
plaque vs not-plaque). Brush a bit, toggle Live Update, correct mistakes, repeat until
the prediction overlay tracks the brown DAB.

Prediction Export -> set Source = Probabilities (NOT Labels — this is the part I
got wrong first), then Choose Export Image Settings → format HDF5.

Batch Processing -> Select Raw Data Files -> select all the real images  -> Process all files.


Output: one .h5 probability map per image, written next to each source TIFF.




### Step 2 — Object Classification (make the CSVs)

ilastik → New Project → Object Classification [Inputs: Raw Data, Pixel Prediction Map].

Build the classifier on ONE image first, get it right, then batch.


Input Data -> "Raw Data" tab: add one TIFF. "Prediction Maps" tab: add its matching
.h5. These two lists must always be the same length and same order.

Threshold and Size Filter -> method Simple, pick the plaque channel, threshold
~0.5. Watch the preview. Raise the threshold + set a minimum object size so it grabs
discrete plaques, not giant merged blobs or single-pixel speckle.

Object Feature Selection -> click All (you can trim later; area + intensity are
the ones that matter).

Object Classification -> turn on Live Update, click a few real plaques → "Plaques",
click a few false detections -> the other class. The "other" class is a reject bin,
not "brain tissue", (it's for throwing out junk detections). If detection is already
clean you can keep this minimal.

Object Information Export -> Configure Feature Table Export -> set location ->
Format = CSV. (Configure this BEFORE batching — Batch Processing uses these settings.
If it's blank you get an "ExportPath not ready" error.)

Batch Processing -> load all Raw Data + all Prediction Maps for a folder
(equal counts, matching order) -> Process all files. Repeat per region folder.

Output: one *_table.csv per section. Each row = one detected object with
Predicted Class, Size in pixels, centroid, bounding box.


### Step 3 — Tissue area in Fiji (the burden denominator)

ilastik only measured plaques, so tissue area has to come from somewhere. Fiji macro
measure_tissue_area.ijm does it in batch.

Fiji -> Plugins -> Macros -> Run -> pick the macro. It prompts for:


1. input folder
2. microns/pixel (your scope's value — needed for real units)
3. minimum tissue particle size in µm² (drops debris outside the section; raise if debris
gets counted, lower if real tissue gets dropped)


It thresholds tissue vs the white slide background (Otsu), fills holes, size-filters out
junk, and writes tissue_areas.csv (filename, area in px / µm² / mm²).


Test it on 2–3 images before trusting all 686. Open one, threshold it manually, confirm
the mask covers tissue and excludes the debris flecks. The denominator scales every
burden number, so it's worth checking first.




### Step 4 — Combine and compute burden (RStudio)




## Data Manipulation
- 061126_tissue_area_table_modifier.R merges all csv files containing pixel area for every tif image
- this outputs pixel_areas.csv into Image_Modeling_and_Analysis
- 061126_Plaque_Counting.R merges all csv files for processed images into one large table
- 061126_Plaque_Counting.R then merges this master table with pixel_areas.csv
- 061126_Plaque_Counting.R finally generates a final table prion_pixel_counts.csv that provides the average total counts, total pixels percentages (relative to brain region), and the standard deviations of each
- For the sake of time, average counts and percentages are based off of 10 images per brain section (cerebellum, hippocampus, midbrain, or septum), per origin (control, Deer, or Elk).
  
## Data Visualization
- Exported data as .csv (object ID and size in pixels)
- Imported .csv files with object ID and size in pixels into R Studio
- Used tidyR and ggplot to clean and plot data


**Table of Data**
- Region of the Brain
- Number of Plaques
- Total infected area
- Origin
- Sample ID #
- Segments of Brain
- Magnification

### Graphs:
**Grouped Violin Plot Comparing Groups**
 - x axis - Brain region
 - y axis - prion burden or aggregate size

  
### Bonus Question
In different regions of the brain, do prion aggregates accumulate as a cluster or as a broad spread?

**Roadblocks**
Do we want to look at how close aggregates are too each other (how clustered they are) or how many clusters there are?

### Output for Bonus Question
**Heat Map**
- diffusivity of the brain
