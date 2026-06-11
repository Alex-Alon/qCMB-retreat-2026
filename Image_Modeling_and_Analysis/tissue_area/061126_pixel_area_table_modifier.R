library(tidyverse)

#define function to include origin and section extracted from files

process_file <- function(file) {
  
  df <- read_csv(file)
  
  labels <- df[[1]]   
  
  Origin <- str_extract(labels, "control|Deer|Elk")
  Section <- str_extract(labels, "cerebellum|hippocampus|midbrain|septum")
  
  tibble(
    File_Name = basename(file),
    Object_Label = labels,
    Origin = Origin,
    Section = Section,
    tissue_area_px = df[[2]]
  )
}

files <- list.files(pattern = "\\.csv$", full.names = TRUE)

all_data <- map_dfr(files, process_file)

all_data <- all_data %>%
  select(-File_Name)

write_csv(all_data, "../pixel_area.csv")
