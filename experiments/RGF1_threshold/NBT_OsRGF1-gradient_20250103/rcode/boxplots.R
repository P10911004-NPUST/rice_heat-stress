suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = "never")
    
    # source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
    source("C:/jklai/github/statools/R/detect_outliers.R")
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    
    theme_set(theme_bw_01)
})

rawdata <- readxl::read_excel("../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_(.*)nM_.*", "\\1")),
        nbt_intensity = nbt_intensity / 1000000,
        nbt_area = nbt_area / 1000000,
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


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Root length ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, root_length ~ treatment)$cld

df0 %>% 
    ggplot(aes(treatment, root_length, color = treatment)) +
    labs(
        y = "Root length (mm)",
        x = "OsRGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(GROUP, MAX + 10, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 100)) +
    theme(
        legend.position = "none"
    )
ggsave2(filename = "root_length.jpg", path = "./figures")


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# NBT total intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, nbt_intensity ~ treatment)$cld

df0 %>% 
    ggplot(aes(treatment, nbt_intensity, color = treatment)) +
    labs(
        y = "NBT total intensity (10<sup>6</sup> DN)",
        x = "OsRGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(GROUP, MAX + 5, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 40)) +
    theme(
        legend.position = "none"
    )
ggsave2(filename = "nbt_total_intensity.jpg", path = "./figures")


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# NBT area ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, nbt_area ~ treatment)$cld

df0 %>% 
    ggplot(aes(treatment, nbt_area, color = treatment)) +
    labs(
        y = "NBT area (10<sup>6</sup> pixels)",
        x = "OsRGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(GROUP, MAX + 0.03, label = CLD),
        size = 8
    ) +
    theme(
        legend.position = "none"
    )
ggsave2(filename = "nbt_area.jpg", path = "./figures")


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Average NBT intensity ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
stats_res <- oneway_test(df0, avg_nbt ~ treatment)$cld
stats_res$cld_pos <- statool::estimate_cld_pos(stats_res$MAX)

df0 %>% 
    ggplot(aes(treatment, avg_nbt, color = treatment)) +
    labs(
        y = "Average NBT intensity<br>(DN / pixel)",
        x = "OsRGF1 (nM)"
    ) +
    geom_boxplot() +
    geom_point() +
    geom_text(
        inherit.aes = FALSE, 
        data = stats_res,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    theme(
        legend.position = "none"
    )
ggsave2(filename = "avg_nbt.jpg", path = "./figures")
