library(tidyverse)


data <- read.csv("prion_pixel_counts.csv")



prion_burden_no_se <- ggplot(data,
       aes(x = Section,
           y = average_plaque_counts,
           fill = Origin)) +
  geom_col(position = position_dodge(width = 0.8),
           color = "black",
           width = 0.7) +
  labs(
    title = "Prion Burden by Brain Region",
    x = "Brain Region",
    y = "% Brain Tissue Detected as Prion",
    fill = "Mouse Model"
  ) +
  scale_fill_brewer(palette = "Set2") +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5,
                              face = "bold",
                              size = 16),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )



prion_burden_with_se <- ggplot(data,
       aes(x = Section,
           y = average_plaque_counts,
           fill = Origin)) +
  geom_col(position = position_dodge(width = 0.8),
           color = "black",
           width = 0.7) +
  geom_errorbar(
    aes(
      ymin = average_plaque_counts - se_percents,
      ymax = average_plaque_counts + se_percents
    ),
    position = position_dodge(width = 0.8),
    width = 0.2,
    linewidth = 0.6
  ) +
  labs(
    title = "Prion Burden by Brain Region",
    x = "Brain Region",
    y = "% Brain Tissue Detected as Prion",
    fill = "Mouse Model"
  ) +
  scale_fill_brewer(palette = "Set2") +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5,
                              face = "bold",
                              size = 16),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    axis.text.x = element_text(hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = "C:/Users/danie/OneDrive - Colostate/CMB documentation/qCMB_retreat/Fuel_the_Build/Image_Modeling_and_Analysis/Prion_Burden_by_Brain_Region.png",
  plot = prion_burden_with_se,
  width = 8,
  height = 6,
  dpi = 300
)





