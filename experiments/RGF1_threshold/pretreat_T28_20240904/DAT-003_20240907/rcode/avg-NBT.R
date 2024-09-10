rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("C:/jklai/project/rice_heat-stress/rcode/utils.R")
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
    filter(
        nbt_area > 0,
        # root_length > 40
    ) %>% 
    mutate(
        DAT = as.numeric(str_replace(img_name, ".*DAT-(\\d\\d\\d).*", "\\1")),
        treatment = as.numeric(str_replace(img_name, ".*(\\d\\d\\d)nM.*", "\\1")),
        REP = as.factor(str_replace(img_name, ".*R(\\d\\d).*", "\\1"))
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 1, 5, 10, 100)),
        group = treatment
    ) %>% 
    group_by(treatment) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    ) %>% 
    ungroup() %>% 
    group_by(treatment, root_type) %>% 
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_intensity_trim_perc, method = "iqr")
    ) %>% 
    ungroup() %>% 
    filter(
        !is_cancel,
        !is_outlier
    )


df0 %>% 
    ggplot(aes(root_length, nbt_intensity_trim_perc, color = treatment, shape = treatment)) +
    geom_point(size = 5, alpha = 0.5) +
    geom_smooth(method = "lm", se = FALSE) +
    # scale_y_continuous(limits = c(100, 200)) +
    scale_shape(
        guide = guide_legend(
            theme = theme(legend.position = "none")
        )
    )


stats_res <- df0 %>% 
    filter(root_type == "long") %>%
    oneway_test(nbt_intensity_trim_perc ~ group)

stats_res <- stats_res$result

# ggplotly(
df0 %>% 
    filter(root_type == "long") %>%
    ggplot(aes(group, nbt_intensity_trim_perc, color = treatment, labels = img_name)) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 10, label = letter),
        size = 8
    )
# )


stats_res <- df0 %>% 
    filter(root_type == "long") %>%
    oneway_test(root_length ~ group)

stats_res <- stats_res$result

df0 %>% 
    filter(root_type == "long") %>%
    ggplot(aes(group, root_length, color = treatment, labels = img_name)) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 10, label = letter),
        size = 8
    )

