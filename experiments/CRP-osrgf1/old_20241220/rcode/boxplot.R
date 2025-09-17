suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    library(tidyverse)
    source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
    source("C:/jklai/github/statools/R/detect_outliers.R")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    
    theme_set(theme_bw_01)
})


rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        genotype = str_replace(img_name, ".*_((M\\d\\d)|WT)_.*", "\\1"),
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_area, use_median = TRUE)
    ) %>% 
    mutate(
        genotype = factor(genotype, levels = c("WT", "M07", "M08", "M15"))
    ) %>% 
    filter(
        nbt_area > 0,
        !is_cancel,
        !is_outlier
    )


# NBT area ====
stats_res <- oneway_test(df0, nbt_area ~ genotype)$result

df0 %>% 
    ggplot(aes(genotype, nbt_area, color = genotype)) +
    labs(subtitle = "NBT area (pixels)") +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank()
    )
ggsave2(filename = "nbt_area.jpg", path = "./figures")


# Root length ====
stats_res <- oneway_test(df0, root_length ~ genotype)$result

df0 %>% 
    ggplot(aes(genotype, root_length, color = genotype)) +
    labs(
        subtitle = "Root length (mm)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(group, letter_pos, label = letter),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.title.x = element_blank(),
        axis.title.y = element_blank()
    )
ggsave2(filename = "root_length.jpg", path = "./figures")






