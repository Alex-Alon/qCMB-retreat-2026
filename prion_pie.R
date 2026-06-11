library(tidyverse)

data <- read.csv("prion_pixel_counts.csv")


pie_data <- data %>%
  filter(Origin != "control") %>%
  group_by(Origin) %>%
  mutate(prop = average_plaque_pixel_percentage /
           sum(average_plaque_pixel_percentage))

pie_chart<- ggplot(pie_data,
       aes(x = "",
           y = prop,
           fill = Section)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  facet_wrap(~ Origin) +
  labs(
    fill = "Brain Region",
    title = "Distribution of Infection by Brain Region"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    strip.text = element_text(face = "bold", size = 12),
    legend.position = "right"
  )

ggsave(
  filename = "C:/Users/danie/OneDrive - Colostate/CMB documentation/qCMB_retreat/Fuel_the_Build/Image_Modeling_and_Analysis/prion_pie_chart.png",
  plot = pie_chart,
  width = 10,
  height = 8,
  dpi = 300
)


