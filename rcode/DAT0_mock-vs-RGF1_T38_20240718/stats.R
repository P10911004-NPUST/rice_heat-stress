suppressMessages({
    rm(list = ls()); gc()
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    library(tidyverse)
    source("https://github.com/P10911004-NPUST/statools/blob/main/R/detect_outliers.R?raw=true")
    source("https://github.com/P10911004-NPUST/statools/blob/main/R/oneway_test.R?raw=true")
    source("https://github.com/P10911004-NPUST/plotools/blob/main/R/utils4ggplot.R?raw=true")
    
    theme_set(theme_bw_01)
})

gradient_colors <- c("#dabfff", "#907ad6", "#4f518c", "#2c2a4a")

# Load data ====
rawdata <- readxl::read_excel("../../img/root_length/DAT0_mock-vs-RGF1_T38_20240718/OUT_DAT0_mock-vs-RGF1_T38_20240718.xlsx")

# Tidy-up ====
df0 <- rawdata %>%  
    mutate(
        DAT = str_replace(img_name, "^DAT(\\d(\\d)?)_.*", "\\1"),
        TEMP = str_replace(img_name, ".*_T(\\d\\d)_.*", "\\1"),
        RGF1_nM = case_when(
            str_detect(img_name, "0nM|mock|Mock") & !str_detect(img_name, "10nM") ~ 0,
            str_detect(img_name, "1nM") ~ 1,
            str_detect(img_name, "5nM") ~ 5,
            str_detect(img_name, "10nM") ~ 10,
            TRUE ~ NA_integer_
        ),
        sample_id = as.numeric(str_replace(img_name, ".*_R(\\d(\\d)?)_.*", "\\1")),
        replicates = as.numeric(str_replace(img_name, ".*_pCr(\\d(\\d)?)_.*", "\\1")),
        group = paste(DAT, RGF1_nM, sep = "_")
    ) %>% 
    mutate(
        RGF1_nM = factor(RGF1_nM, levels = c(0, 1, 5, 10))
    ) %>% 
    group_by(group) %>%
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_intensity_per_area, method = "iqr", use_median = TRUE)
    ) %>% 
    ungroup(group) %>%
    filter(!is_cancel, !is_outlier) %>% 
    arrange(sample_id)


# Multiple comparison ====
## NBT intensity ====
stats_res <- df0 %>% 
    oneway_test(nbt_intensity_per_area ~ RGF1_nM) %>% 
    .$results

df0 %>% 
    ggplot(aes(RGF1_nM, nbt_intensity_per_area, color = RGF1_nM)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        x = "RGF1 treatment (nM)",
        y = "Average NBT intensity<br>(DN / pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 20, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )

ggsave(
    filename = "nbt_intensity.jpeg",
    path = "./figures",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 12,
    width = 17
)


## Root length ====
stats_res <- df0 %>% 
    oneway_test(root_length ~ RGF1_nM) %>% 
    .$results

df0 %>% 
    ggplot(aes(RGF1_nM, root_length, color = RGF1_nM)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        x = "RGF1 treatment (nM)",
        y = "Root length (mm)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 60), breaks = seq(0, 60, 10)) +
    scale_color_manual(values = gradient_colors) +
    theme(
        legend.position = "none",
        plot.subtitle = element_markdown()
    )

ggsave(
    filename = "root_length.jpeg",
    path = "./figures",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 12,
    width = 17
)


# # Correlation (root_length vs average_nbt) ====
# corr <- correlation::correlation(
#     data = df0, 
#     select = "root_length", 
#     select2 = "nbt_intensity_per_area"
# ) %>% 
#     as_tibble()
# 
# df0 %>% 
#     ggplot(aes(root_length, nbt_intensity_per_area)) +
#     labs(
#         subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
#         x = "Root length (mm)",
#         y = "Average NBT intensity<br>(DN / pixels)"
#     ) +
#     geom_point(mapping = aes(color = RGF1_nM)) +
#     geom_smooth(method = "lm", se = FALSE, color = "black") +
#     scale_x_continuous(limits = c(10, 50)) +
#     scale_y_continuous(limits = c(170, 210)) +
#     scale_color_hue(
#         labels = c("Mock", "1 nM", "5 nM", "10 nM")
#     ) +
#     theme(
#         legend.position = "inside",
#         legend.position.inside = c(0.5, 0.9),
#         legend.title = element_blank(),
#         plot.subtitle = element_markdown()
#     )




