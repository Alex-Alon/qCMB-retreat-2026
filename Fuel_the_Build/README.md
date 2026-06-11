# Fuel_the_Build

## Pipeline designed for PrP Deposition Imagine Challenge

#### Team Leader: Alex Alon
#### Image Visaluzation and Automation Lead: Ryan Eastman
#### Data Manipulation and Visualization Leads: Marisa Foster and Danielle Samson

### Pipeline Approach: Snakemake

### Biological Question:
How does prion aggregation differ between elk and deer, and how does it differ based on region of the brain?


**Roadbloacks**
1. How do we distinguish between plaques and aggregates?
2. Determining the area of aggregates and plaques depends on how we quanitfy the area?
3. How do we get rid of background and account for false staining?
4. How do we normalize to WT?
5. Images have a certain dpi, so it may be hard to count aggregates in a cluster because it is blurry when we zoom in. How do we account for error?
6. Some aggregates are bold while some are faded based on where they are in the z field of the image. How do we account for different intensities of aggregates?


# Workflow

### Image Processing
make greyscale
resize every image


### Desired Outputs:
**Annotated Images Containing**
- Brain region
- Sample origin – deer, elk, or WT
- Sample ID #
- Magnification

**Table of Data**
- Region of the Brain
- Number of aggregates
- Number of Plaques
- Origin
- Sample ID #
- Segments of Brain
- Magnification

### Graphs:
**Scatter Plot to give confidence in the model**
 - x axis - "observed" trained MRL
 - y axis - predicted MRL
 - r^2 value should be close to 1.0
 
**Bar Graph**
-  facet by brain region
-  ggarrange two graphs: deer and elk

**Pie Chart**
-  % in brain based on animal of origin
  
### Bonus Question
In different regions of the brain, do prion aggregates accumulate as a cluster or as a broad spread?

**Roadblocks**
Do we want to look at how close aggregates are too each other (how clustered they are) or how many clusters there are?

### Output for Bonus Question
**Heat Map**
- diffusivity of the brain
