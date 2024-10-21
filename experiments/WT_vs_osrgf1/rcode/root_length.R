library(tidyverse)
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")

theme_set(theme_bw_01)

rawdata <- readxl::read_excel("../root_length/OUT_WT_vs_osrgf1-1_20241014.xlsx")

df0 <- rawdata %>% 
    mutate(
        genotype = str_replace(img_name, "(.*)_R\\d\\d_.*", "\\1"),
        genotype = case_when(
            str_detect(genotype, "F7") ~ "#7_4_10",
            str_detect(genotype, "F8") ~ "#8_9_6_3",
            TRUE ~ genotype
        ),
        genotype = factor(genotype, levels = c("WT", "#8_9_6_3", "#7_4_10")),
        nbt_area = nbt_area / 1000
    ) %>% 
    group_by(genotype) %>% 
    filter(
        !detect_outliers(nbt_area),
        !str_detect(img_name, "_cancel_"),
        # genotype != "#7_4_10"
    ) %>% 
    ungroup()

stats_res <- oneway_test(df0, root_length ~ genotype)
stats_res <- stats_res$result

df0 %>% 
    ggplot(aes(genotype, root_length, color = genotype)) +
    labs(
        subtitle = "Root length (mm)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_pos + 5, label = letter),
        size = 10
    ) +
    theme(
        axis.text.x.bottom = element_markdown(size = 23),
        axis.title.x.bottom = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none"
    )

ggsave(
    filename = "root_length.jpg",
    path = "./figures/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)
