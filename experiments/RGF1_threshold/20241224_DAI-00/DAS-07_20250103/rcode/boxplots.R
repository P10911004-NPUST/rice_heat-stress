suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    
    source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
    source("C:/jklai/github/statools/R/detect_outliers.R")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_(.*)nM_.*", "\\1")),
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_area)
    ) %>% 
    mutate(
        treatment = as.factor(treatment)
    ) %>% 
    filter(
        !is_cancel,
        # !is_outlier
    )


# Root length ====
stats_res <- oneway_test(df0, root_length ~ treatment)$result

df0 %>% 
    ggplot(aes(treatment, root_length, color = treatment)) +
    labs(
        subtitle = "Root length (mm)",
        x = "OsRGF1 concentration (nM)"
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
        axis.title.y = element_blank()
    )
ggsave2(filename = "root_length.jpg", path = "./figures")


# NBT area ====
stats_res <- oneway_test(df0, nbt_area ~ treatment)$result

df0 %>% 
    ggplot(aes(treatment, nbt_area, color = treatment)) +
    labs(
        subtitle = "NBT area (pixels)",
        x = "OsRGF1 concentration (nM)"
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
        axis.title.y = element_blank()
    )
ggsave2(filename = "nbt_area.jpg", path = "./figures")


