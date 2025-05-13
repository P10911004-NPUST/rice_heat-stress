suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    
    library(tidyverse)
    source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    source("C:/jklai/github/statools/R/detect_outliers.R")
    
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    select(img_name, nbt_area, nbt_intensity, trim_avg_nbt, root_length) %>% 
    mutate(
        treatment = as.factor(as.numeric(str_replace(img_name, ".*_(.*)nM_.*", "\\1"))),
        nbt_area = nbt_area / 1e6,
        is_cancel = str_detect(img_name, "cancel")
    ) %>% 
    filter(!is_cancel)


# NBT area ====
stats_res <- oneway_test(df0, nbt_area ~ treatment)
stats_res$perform_test
stats_res <- stats_res$result

ggplot(df0, aes(treatment, nbt_area, color = treatment)) +
    labs(
        subtitle = "NBT area (10<sup>6</sup> pixels)",
        x = "RGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.title.y = element_blank()
    )
ggsave2(filename = "nbt_area.jpg", path = "./figures")


# root length ====
stats_res <- oneway_test(df0, root_length ~ treatment)
stats_res$perform_test
stats_res <- stats_res$result

ggplot(df0, aes(treatment, root_length, color = treatment)) +
    labs(
        subtitle = "Root length (mm)",
        x = "RGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    ) +
    theme(
        legend.position = "none",
        axis.title.y = element_blank()
    )
ggsave2(filename = "root_length.jpg", path = "./figures")



