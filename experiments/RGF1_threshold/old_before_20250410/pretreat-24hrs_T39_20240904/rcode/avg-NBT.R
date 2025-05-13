rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("../../../../rcode/utils.R")
source("C:/jklai/github/statools/R/oneway_test.R")
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")

theme_set(theme_bw_01)

file_list <- list.files("../", pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE) %>% 
    str_subset("OUT_NBT")

rawdata <- file_list %>% 
    map(readxl::read_excel) %>% 
    list_rbind()

df0 <- rawdata %>% 
    filter(nbt_area > 0) %>% 
    mutate(
        DAT = as.numeric(str_replace(img_name, ".*DAT-(\\d\\d\\d).*", "\\1")),
        treatment = as.numeric(str_replace(img_name, ".*(\\d\\d\\d)nM.*", "\\1"))
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 1, 5, 10, 100)),
        group = treatment
    ) %>% 
    group_by(treatment) %>% 
    mutate(
        root_type = def_long_short_root(nbt_area)
    ) %>% 
    ungroup() %>% 
    group_by(treatment, root_type) %>% 
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_area, method = "iqr")
    ) %>% 
    ungroup() %>% 
    filter(!is_cancel, !is_outlier)


df0 %>% 
    ggplot(aes(nbt_area, nbt_intensity_trim_perc, color = treatment, shape = treatment)) +
    geom_point(size = 5, alpha = 0.5) +
    geom_smooth(method = "lm", formula = y ~ x + I(x^2), se = FALSE) +
    scale_y_continuous(limits = c(100, 200)) +
    scale_shape(
        guide = guide_legend(
            theme = theme(legend.position = "none")
        )
    )


stats_res <- df0 %>% 
    filter(root_type == "short") %>% 
    oneway_test(nbt_area ~ group)

stats_res <- stats_res$result
stats_res %>% arrange(MED)


df0 %>% 
    ggplot(aes(group, nbt_area, color = treatment)) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    )




