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

# Average NBT ====
for (i in 1:nrow(comb_tab)){
    
    purpose_ <- as.character(comb_tab[i, "purpose"])
    DAT_ <- as.character(comb_tab[i, "DAT"])
    root_type_ <- as.character(comb_tab[i, "root_type"])
    
    if (purpose_ == "protect" & DAT_ == "0" & root_type_ == "long") next
        
    df1 <- df0 %>% 
        filter(
            purpose == purpose_,
            DAT == DAT_,
            root_type == root_type_
        )
    
    stats_res <- oneway_test(df1, nbt_intensity_trim_perc ~ treatment)
    stats_res <- stats_res$result
    
    df1 %>% 
        ggplot(aes(treatment, nbt_intensity_trim_perc, color = treatment)) +
        labs(
            x = "RGF1 (nM)",
            y = "Avg NBT intensity",
            subtitle = sprintf("DAT%s (%s roots)", DAT_, root_type_)
        ) +
        geom_point() +
        geom_boxplot() +
        geom_text(
            inherit.aes = FALSE,
            data = stats_res,
            mapping = aes(group, letter_y_pos - 15, label = letter),
            size = 8
        ) +
        theme(
            legend.position = "none"
        )
    
    ggsave(
        filename = sprintf("Avg-NBT_%s_DAT%s_%s.jpeg", purpose_, DAT_, root_type_),
        path = "./",
        device = "jpeg",
        units = "cm",
        dpi = 330,
        height = 12,
        width = 17
    )
}


# Protective effect ====
## DAT0 ====
df1 <- df0 %>% 
    filter(DAT == 0, purpose == "protect")

stats_res <- df1 %>% 
    oneway_test(nbt_intensity_trim_perc ~ treatment)
stats_res <- stats_res$result

df1 %>% 
    ggplot(aes(treatment, nbt_intensity_trim_perc, color = treatment)) +
    labs(
        subtitle = "DAT0 (long roots)",
        x = "RGF1 (nM)",
        y = "Avg NBT intensity",
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 14, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(170, 210)) +
    theme(
        legend.position = "none"
    )

ggsave(
    filename = "Avg-NBT_protect_DAT0_long.jpeg",
    path = "./",
    device = "jpeg",
    dpi = 330,
    units = "cm",
    height = 12,
    width = 17
)


