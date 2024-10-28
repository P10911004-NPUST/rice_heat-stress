rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()
set.seed(1)

library(tidyverse)
library(plotly)
source("../../../../rcode/utils.R")
source("C:/jklai/github/statools/R/oneway_test.R", chdir = TRUE)
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/github/plotools/R/utils4ggplot.R")

theme_set(theme_bw_01)

file_list <- list.files("../", pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE) %>% 
    str_subset("OUT_NBT")

rawdata <- file_list %>% 
    map(readxl::read_excel) %>% 
    list_rbind()

df0 <- rawdata %>% 
    mutate(
        DAT = factor(
            as.numeric(str_replace(img_name, "^DAT(\\d(\\d)?)_.*", "\\1")),
            levels = c(0, 5, 10)
        ),
        sample_id = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1"))
    ) %>% 
    mutate(
        treatment = case_when(
            sample_id %in% c( 1:3, 13:15) ~ "0",
            sample_id %in% c( 4:6, 16:18) ~ "1",
            sample_id %in% c( 7:9, 19:21) ~ "5",
            sample_id %in% c(10:12, 22:24) ~ "10",
            TRUE ~ NA_character_
        ),
        purpose = case_when(
            sample_id %in% 1:12 ~ "protect",
            sample_id %in% 13:24 ~ "recover",
            TRUE ~ NA_character_
        )
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 1, 5, 10)),
        group = treatment
    ) %>% 
    group_by(DAT, treatment, purpose) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    ) %>% 
    ungroup() %>% 
    group_by(DAT, treatment, purpose, root_type) %>% 
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_intensity_trim_perc, method = "iqr")
    ) %>% 
    ungroup() %>% 
    filter(!is_cancel, !is_outlier) %>% 
    arrange(sample_id)

comb_tab <- expand.grid(
    purpose = unique(df0$purpose), 
    DAT = unique(df0$DAT), 
    root_type = unique(df0$root_type)
)


df0 %>% 
    filter(
        purpose == "protect",
        DAT != 0,
        # treatment %in% c(0, 5, 10)
    ) %>% 
    ggplot(aes(root_length, color = treatment, fill = treatment)) +
    geom_density(alpha = 0.1)












