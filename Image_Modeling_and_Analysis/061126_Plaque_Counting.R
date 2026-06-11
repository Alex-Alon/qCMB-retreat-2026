library(tidyverse)
library(emmeans)
#grab all csv files except the pixel_area file

files <- list.files(
  path = ".",
  pattern = "\\.csv$",
  full.names = TRUE
)
files <- files[basename(files) != "pixel_area.csv"]
files <- files[basename(files) != "prion_pixel_counts.csv"]
process_file <- function(file) {
  
  
#retrieve from file name what the origins and brain sections are for each file
  
  filename <- basename(file)
  
  origin <- case_when(
    str_detect(filename, "control") ~ "Control",
    str_detect(filename, "Elk") ~ "Elk",
    str_detect(filename, "Deer") ~ "Deer",
    TRUE ~ NA_character_
  )
  
  section <- case_when(
    str_detect(filename, "cerebellum") ~ "Cerebellum",
    str_detect(filename, "hippocampus") ~ "Hippocampus",
    str_detect(filename, "midbrain") ~ "Midbrain",
    str_detect(filename, "septum") ~ "Septum",
    TRUE ~ NA_character_
  )
  
  read.csv(file, fill = TRUE, header = TRUE) %>%
    select(object_id, Size.in.pixels) %>%
    mutate(
      Origin = origin,
      Section = section,
      File = filename
    )
}

#merge into a master file

master <- map_dfr(files, process_file)

#prep master and pixel_area tables to be mergable by file_id
master <- master %>%
  rename(file_id = File) %>%
  mutate(file_id = str_remove(file_id, "\\_table.tif$|\\_table.csv$"))


pixel_area <- read.csv("pixel_area.csv", fill = TRUE, header = TRUE)
pixel_area <- pixel_area %>%
  rename(file_id = Object_Label) %>%
  mutate(file_id = str_remove(file_id, "\\.tif$"))


merged <- master %>%
  left_join(pixel_area, by = "file_id")


#complete summary statistics: total # plaques, total # pixels, percent pixels relative to section pixels in each image
summary_table <- merged %>%
  group_by(file_id, Origin.y, Section.y, tissue_area_px) %>%
  summarize(
    Total_Plaques = n(),
    Total_Plaque_Pixels = sum(Size.in.pixels, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Percent_Pixel_Plaques =
      100 * Total_Plaque_Pixels / tissue_area_px
  )

se <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))}

final_table <- summary_table %>%
  group_by(Origin.y, Section.y) %>%
  summarize(
            average_plaque_counts = mean(Total_Plaques),
            average_plaque_pixels = mean(Total_Plaque_Pixels),
            average_plaque_pixel_percentage = mean(Percent_Pixel_Plaques),
            sd_counts = sd(Total_Plaques),
            sd_percents = sd(Percent_Pixel_Plaques),
            se_counts =  sd(Total_Plaques, na.rm = TRUE) / sqrt(sum(!is.na(Total_Plaques))),
            se_percents = sd(Percent_Pixel_Plaques, na.rm = TRUE) / sqrt(sum(!is.na(Percent_Pixel_Plaques)))) %>%
  rename(Origin = Origin.y, Section = Section.y)


write_csv(final_table, "prion_pixel_counts.csv")

model <- aov(Percent_Pixel_Plaques ~ Origin.y * Section.y, data = summary_table)
emmeans(model, pairwise ~ Origin.y | Section.y)

