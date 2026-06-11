## This folder contains code for:
- uploading the image files
- image processing using Fiji and Ilastik
- plaque quantification
- an output that includes all categorical and numerical variables that can be obtained from the data

## Image Processing:


We found a MLM called DeepSlice
- https://github.com/PolarBean/DeepSlice 
- https://www.deepslice.com.au/ 
DeepSlice aligns histological sections of mouse brain to the Allen Mouse Brain Common Coordinate Framework, adjusting for anterior-posterior position, angle, rotation, and scale.

We need to specifically align our images to the: 
- cerebellum
- hippocampus
- midbran
- septum

**We accounted for the following:**

- Problem | Solution
- Different colors of images | greyscale all images
- All different angles | rotate all images to the same angle
- Folded samples | discard
- Multiple cerebellums on one slide
- Overlapped images | discard if heavily overlapped
- Zoomed images that cannot be mapped | discard


## Building a Model for Aggregate and Plaque Quantification

Model Used: Stardist (training with a GUI)

**Roadblocks**
- without Z-stacks we cannot determine whether a dark pixel represents one, or multiple aggregates
- image quality is poor so we cannot cleanly discern how many aggregates/plaques there are
- did not have time to train a more complex model that we worked on originally


