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
rawdata <- readxl::read_excel("../../img/root_length/DAT0_28-vs-32_20240720/OUT_DAT0_28-vs-32_20240720.xlsx")

# Tidy-up ====
df0 <- rawdata %>%  
    mutate(
        DAT = str_replace(img_name, "^DAT(\\d(\\d)?)_.*", "\\1"),
        TEMP = str_replace(img_name, ".*_T(\\d\\d)_.*", "\\1"),
        sample_id = as.numeric(str_replace(img_name, ".*_R(\\d(\\d)?)_.*", "\\1")),
        replicates = as.numeric(str_replace(img_name, ".*_pCr(\\d(\\d)?)_.*", "\\1"))
    ) %>% 
    group_by(TEMP) %>%
    mutate(
        is_cancel = str_detect(img_name, "cancel"),
        is_outlier = detect_outliers(nbt_intensity_per_area, method = "iqr", use_median = TRUE)
    ) %>% 
    ungroup() %>%
    filter(!is_cancel, !is_outlier) %>% 
    arrange(sample_id)


# Multiple comparison ====
## NBT intensity ====
stats_res <- df0 %>% 
    oneway_test(nbt_intensity_per_area ~ TEMP) %>% 
    .$results

df0 %>% 
    ggplot(aes(TEMP, nbt_intensity_per_area, color = TEMP)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 28&deg;C)",
        x = "Temperature (&deg;C)",
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
    # scale_y_continuous(limits = c(170, 210), breaks = seq(170, 210, 10)) +
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
    oneway_test(root_length ~ TEMP) %>% 
    .$results

df0 %>% 
    ggplot(aes(TEMP, root_length, color = TEMP)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 28&deg;C)",
        x = "Temperature (&deg;C)",
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
    # scale_y_continuous(limits = c(0, 60), breaks = seq(0, 60, 10)) +
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


# Correlation (root_length vs average_nbt) ====
corr <- correlation::correlation(
    data = df0,
    select = "root_length",
    select2 = "nbt_intensity_per_area"
) %>%
    as_tibble() %>% 
    mutate(
        r = round(r, 3),
        p = num2asterisk(p)
    ) %>% 
    select(Parameter1, Parameter2, r, p)

corr_anno <- ifelse(
    corr$r < 0,
    paste0("r = &minus;", abs(corr$r), "<sup>", corr$p, "</sup>"),
    paste0("r = ", corr$r, "<sup>", corr$p, "</sup>")
)
    
df0 %>%
    ggplot(aes(root_length, nbt_intensity_per_area)) +
    labs(
        subtitle = "DAT0 (Control &rarr; Mock + 30&deg;C)",
        x = "Root length (mm)",
        y = "Average NBT intensity<br>(DN / pixels)"
    ) +
    geom_point(mapping = aes(color = TEMP)) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        label = list(corr_anno),
        x = 25,
        y = 235,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 85), breaks = seq(5, 85, 20)) +
    scale_y_continuous(limits = c(160, 250)) +
    scale_color_hue(labels = c("28&deg;C", "32&deg;C")) +
    theme(
        legend.direction = "vertical",
        legend.position = "inside",
        legend.position.inside = c(0.85, 0.8),
        legend.title = element_blank(),
        plot.subtitle = element_markdown()
    )




