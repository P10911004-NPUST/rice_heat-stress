rm(list = ls()); gc()

library(tidyverse)
source("C:/jklai/github/statools/R/oneway_test.R")
source("C:/jklai/github/statools/R/detect_outliers.R")
source("C:/jklai/project/rice_heat-stress/rcode/utils.R")
source("https://github.com/P10911004-NPUST/plotools/blob/main/R/utils4ggplot.R?raw=true")

theme_set(theme_bw_01)

file_list <- list.files("../", pattern = "\\.xlsx$", full.names = TRUE, recursive = TRUE) %>%
    str_subset("OUT_NBT")

file_list

rawdata <- readxl::read_excel(file_list[1])

df0 <- rawdata %>% 
    mutate(
        treatment = as.numeric(str_replace(img_name, ".*_((\\d)?(\\d)?(\\d)?)nM_.*", "\\1")),
        sample_id = as.numeric(str_replace(img_name, ".*_R(\\d\\d)_.*", "\\1")),
        is_survive = case_when(
            nbt_area > 0 ~ 1,
            nbt_area == 0 ~ 0,
            TRUE ~ NA_integer_
        )
    ) %>% 
    mutate(
        treatment = factor(treatment, levels = c(0, 50, 100)),
        group = treatment
    ) %>% 
    group_by(treatment) %>% 
    mutate(
        root_type = def_long_short_root(root_length)
    ) %>% 
    ungroup()

df1 <- df0 %>% 
    filter(root_type == "long")
    # filter(nbt_intensity_trim_perc > 0)

df1 %>% 
    summarise(
        survival_rate = mean(is_survive) * 100,
        .by = c(treatment, root_type, sample_id)
    )

stats_res <- df1 %>% 
    oneway_test(nbt_intensity_trim_perc ~ treatment, use_art = TRUE)

stats_res <- stats_res$result

df1 %>% 
    ggplot(aes(group, nbt_intensity_trim_perc)) +
    labs(
        subtitle = "DAT0",
        x = "RGF1 (nM)",
        y = "Avg NBT intensity"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 15, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(180, 210))

ggsave(
    filename = "boxplot.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 330,
    height = 12,
    width = 17
)
