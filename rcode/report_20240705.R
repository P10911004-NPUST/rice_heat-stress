rm(list = ls()); gc()
if (!is.null(dev.list())) dev.off()

library(tidyverse)
library(ggsignif)
library(ggtext)

source("https://github.com/P10911004-NPUST/plotools/blob/main/R/utils4ggplot.R?raw=true")
source("https://github.com/P10911004-NPUST/plotools/blob/main/R/color_palette.R?raw=true")
source("https://github.com/P10911004-NPUST/statools/blob/main/R/oneway_test.R?raw=true")
source("https://github.com/P10911004-NPUST/statools/blob/main/R/detect_outliers.R?raw=true")
# source("C:/jklai/github/plotools/R/utils4ggplot.R")
theme_set(theme_bw_02)

# Read files ====
file_list <- list.files("../img/NBT", pattern = "OUT.*\\.xlsx", full.names = TRUE)

rawdata <- map(file_list, readxl::read_excel) %>% 
    list_rbind()

df0 <- rawdata %>% 
    mutate(
        nbt_intensity = nbt_intensity / 1e6,
        nbt_area = nbt_area / 1e4,
        img_name = str_remove_all(img_name, " "),
        DAT = str_replace(img_name, "^DAT(\\d\\d?)_.*", "\\1"),
        temperature = str_replace(img_name, ".*_T(\\d\\d)_.*", "\\1"),
        group = paste(temperature, DAT, sep = "_"),
        replicates = str_replace(img_name, ".*_R([:digit:])_.*", "\\1"),
        is_cancel = str_detect(img_name, "cancel")
    ) %>% 
    mutate(
        DAT = factor(DAT, levels = c(0, 5)),
        temperature = factor(temperature, levels = c(32, 34, 36, 38))
    )

df0 <- df0 %>%
    filter(nbt_intensity_per_area != 0, root_length < 30) %>%
    filter(!is_cancel) %>% 
    select(-img_name, -is_cancel)


corr_df <- df0 %>% 
    group_by(group) %>% 
    correlation::correlation(
        select = "nbt_intensity_per_area",
        select2 = "root_length" 
    ) %>% 
    ungroup() %>% 
    as_tibble() %>% 
    select(Group, r, p) %>% 
    mutate(sym = num2asterisk(p))


# DAT5 ====
## Correlation ====
### NBT intensity per area ====
anno <- df0 %>% 
    filter(DAT == 5) %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_intensity_per_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(root_length, nbt_intensity_per_area)) +
    labs(
        x = "Root length (mm)",
        y = "Average NBT intensity<br>(DN/pixel)"
    ) +
    geom_point(
        inherit.aes = FALSE,
        mapping = aes(root_length, nbt_intensity_per_area, color = temperature)
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 25,
        y = 225,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 41)) +
    scale_y_continuous(limits = c(140, 240)) +
    scale_color_manual(
        values = c("navyblue", "skyblue", "orange1", "red4"),
        labels = paste(levels(df0$temperature), "&deg;C", sep = "")
    ) +
    theme(
        legend.title = element_blank()
    )

ggsave(
    filename = "root-length_vs_nbt-intensity-per-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)

### Total NBT intensity ====
anno <- df0 %>% 
    filter(DAT == 5) %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_intensity"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(root_length, nbt_intensity)) +
    labs(
        x = "Root length (mm)",
        y = "Total NBT intensity<br>(DN &times; 10<sup>6</sup>)"
    ) +
    geom_point(
        inherit.aes = FALSE,
        mapping = aes(root_length, nbt_intensity, color = temperature)
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 25,
        y = 17,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 41)) +
    scale_y_continuous(limits = c(0, 20)) +
    scale_color_manual(
        values = c("navyblue", "skyblue", "orange1", "red4"),
        labels = paste(levels(df0$temperature), "&deg;C", sep = "")
    ) +
    theme(
        legend.title = element_blank()
    )

ggsave(
    filename = "root-length_vs_nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area ====
anno <- df0 %>% 
    filter(DAT == 5) %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(root_length, nbt_area)) +
    labs(
        x = "Root length (mm)",
        y = "NBT area<br>(pixels &times; 1000)"
    ) +
    geom_point(
        inherit.aes = FALSE,
        mapping = aes(root_length, nbt_area, color = temperature)
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 25,
        y = 8,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 41)) +
    scale_y_continuous(limits = c(0, 10)) +
    scale_color_manual(
        values = c("navyblue", "skyblue", "orange1", "red4"),
        labels = paste(levels(df0$temperature), "&deg;C", sep = "")
    ) +
    theme(
        legend.title = element_blank()
    )

ggsave(
    filename = "root-length_vs_nbt-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area vs average intensity ====
anno <- df0 %>% 
    filter(DAT == 5) %>% 
    correlation::correlation(
        select = "nbt_area", 
        select2 = "nbt_intensity_per_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(nbt_area, nbt_intensity_per_area)) +
    labs(
        x = "NBT area (pixels &times; 1000)",
        y = "Average NBT intensity<br>(DN &times; 10<sup>6</sup>)"
    ) +
    geom_point(
        inherit.aes = FALSE,
        mapping = aes(nbt_area, nbt_intensity_per_area, color = temperature)
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 6,
        y = 170,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_color_manual(
        values = c("navyblue", "skyblue", "orange1", "red4"),
        labels = paste(levels(df0$temperature), "&deg;C", sep = "")
    ) +
    theme(
        legend.title = element_blank()
    )

ggsave(
    filename = "nbt-area_vs_nbt-intensity-per-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area vs intensity ====
anno <- df0 %>% 
    filter(DAT == 5) %>% 
    correlation::correlation(
        select = "nbt_area", 
        select2 = "nbt_intensity"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

df0 %>% 
    filter(DAT == 5) %>% 
    ggplot(aes(nbt_area, nbt_intensity)) +
    labs(
        x = "NBT area (pixels &times; 1000)",
        y = "Total NBT intensity<br>(DN &times; 10<sup>6</sup>)"
    ) +
    geom_point(
        inherit.aes = FALSE,
        mapping = aes(nbt_area, nbt_intensity, color = temperature)
    ) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 2,
        y = 13,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_color_manual(
        values = c("navyblue", "skyblue", "orange1", "red4"),
        labels = paste(levels(df0$temperature), "&deg;C", sep = "")
    ) +
    theme(
        legend.title = element_blank()
    )

ggsave(
    filename = "nbt-area_vs_nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


## Multiple comparison ====
### NBT intensity per area ====
DAT5 <- filter(df0, DAT == 5)
# DAT5 <- DAT5 %>% 
#     group_by(group) %>% 
#     mutate(outliers = detect_outliers(nbt_intensity_per_area, use_median = TRUE, n.sd = 2)) %>% 
#     ungroup() %>% 
#     filter(!outliers)

stats_res <- oneway_test(DAT5, nbt_intensity_per_area ~ temperature)
stats_res <- stats_res$results

DAT5 %>% 
    ggplot(aes(temperature, nbt_intensity_per_area, color = temperature)) +
    labs(
        x = "Temperature (&deg;C)",
        y = "Average NBT intensity<br>(DN/pixel)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos - 15, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(165, 225), breaks = seq(165, 225, 20)) +
    scale_color_manual(values = c("navyblue", "skyblue", "orange1", "red4")) +
    theme(
        legend.title = element_blank(),
        legend.position = "none"
    )

ggsave(
    filename = "multcomp_average-nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### Total NBT intensity ====
DAT5 <- filter(df0, DAT == 5)

stats_res <- oneway_test(DAT5, nbt_intensity ~ temperature)
stats_res <- stats_res$results

DAT5 %>% 
    ggplot(aes(temperature, nbt_intensity, color = temperature)) +
    labs(
        x = "Temperature (&deg;C)",
        y = "Total NBT intensity<br>(DN &times; 10<sup>6</sup>)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos + 1, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 20), breaks = seq(0, 20, 5)) +
    scale_color_manual(values = c("navyblue", "skyblue", "orange1", "red4")) +
    theme(
        legend.title = element_blank(),
        legend.position = "none"
    )

ggsave(
    filename = "multcomp_total-nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area ====
DAT5 <- filter(df0, DAT == 5)

stats_res <- oneway_test(DAT5, nbt_area ~ temperature)
stats_res <- stats_res$results

DAT5 %>% 
    ggplot(aes(temperature, nbt_area, color = temperature)) +
    labs(
        x = "Temperature (&deg;C)",
        y = "NBT area<br>(pixels &times; 1000)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos + 0.5, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 10), breaks = seq(0, 10, 2)) +
    scale_color_manual(values = c("navyblue", "skyblue", "orange1", "red4")) +
    theme(
        legend.title = element_blank(),
        legend.position = "none"
    )

ggsave(
    filename = "multcomp_nbt-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### Root length ====
DAT5 <- filter(df0, DAT == 5)
DAT5 <- DAT5 %>% 
    group_by(group) %>% 
    mutate(outliers = detect_outliers(root_length, use_median = TRUE, n.sd = 2)) %>% 
    ungroup() %>% 
    filter(!outliers)

stats_res <- oneway_test(DAT5, root_length ~ temperature)
stats_res <- stats_res$results

DAT5 %>% 
    ggplot(aes(temperature, root_length, color = temperature)) +
    labs(
        x = "Temperature (&deg;C)",
        y = "Root length (mm)"
    ) +
    geom_point() +
    geom_boxplot() +
    geom_text(
        inherit.aes = FALSE,
        data = stats_res,
        mapping = aes(group, letter_y_pos + 3, label = letter),
        size = 8
    ) +
    scale_y_continuous(limits = c(0, 40)) +
    scale_color_manual(values = c("navyblue", "skyblue", "orange1", "red4")) +
    theme(
        legend.title = element_blank(),
        legend.position = "none"
    )

ggsave(
    filename = "multcomp_root-length.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


# DAT0 ====
DAT0 <- df0 %>% 
    filter(DAT == 0) %>% 
    mutate(temperature = factor(temperature, levels = unique(.$temperature)))

## Correlation ====
### NBT intensity per area ====
anno <-  DAT0 %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_intensity_per_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

DAT0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(root_length, nbt_intensity_per_area)) +
    labs(
        x = "Root length (mm)",
        y = "Average NBT intensity<br>(DN/pixel)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 25,
        y = 215,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 40)) +
    scale_y_continuous(limits = c(180, 220))

ggsave(
    filename = "root-length_vs_nbt-intensity-per-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### Total NBT intensity ====
anno <-  DAT0 %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_intensity"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

DAT0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(root_length, nbt_intensity)) +
    labs(
        x = "Root length (mm)",
        y = "Total NBT intensity (DN)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 31,
        y = 15,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 40)) +
    scale_y_continuous(limits = c(0, 18))

ggsave(
    filename = "root-length_vs_nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area ====
anno <-  DAT0 %>% 
    correlation::correlation(
        select = "root_length", 
        select2 = "nbt_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

DAT0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(root_length, nbt_area)) +
    labs(
        x = "Root length (mm)",
        y = "NBT area (pixels)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 31,
        y = 7,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    ) +
    scale_x_continuous(limits = c(5, 40)) +
    scale_y_continuous(limits = c(0, 8))

ggsave(
    filename = "root-length_vs_nbt-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area vs intensity ====
anno <-  DAT0 %>% 
    correlation::correlation(
        select = "nbt_area", 
        select2 = "nbt_intensity"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

DAT0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(nbt_area, nbt_intensity)) +
    labs(
        x = "NBT area (pixels)",
        y = "NBT intensity (DN)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 3,
        y = 13,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    )

ggsave(
    filename = "nbt-area_vs_nbt-intensity.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


### NBT area vs average intensity ====
anno <-  DAT0 %>% 
    correlation::correlation(
        select = "nbt_area", 
        select2 = "nbt_intensity_per_area"
    ) %>% 
    as_tibble() %>% 
    select(r, p) %>% 
    mutate(sym = num2asterisk(p))

anno <- sprintf("r = %s<sup>%s</sup>", round(anno$r, 3), anno$sym)

DAT0 %>% 
    filter(DAT == 0) %>% 
    ggplot(aes(nbt_area, nbt_intensity_per_area)) +
    labs(
        x = "NBT area (pixels)",
        y = "Average NBT intensity<br>(DN/pixels)"
    ) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    annotate(
        geom = "richtext",
        x = 6,
        y = 190,
        label = anno,
        fill = NA,
        label.color = NA,
        size = 8
    )

ggsave(
    filename = "nbt-area_vs_nbt-intensity-per-area.jpeg",
    path = "./",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 12,
    width = 17
)


#<<<<<<<<<<<<<<<====
# # T34 ====
# for (dat in unique(df0$DAT)){
#     cor_group <- paste(dat, "34", sep = " - ")
#     T34 <- list(
#         data = df0 %>% filter(DAT == dat, temperature == 34),
#         r = round((corr_df %>% filter(Group == cor_group))$r, 2),
#         p = num2asterisk((corr_df %>% filter(Group == cor_group))$p)
#     )
#     T34$anno <- bquote( "r ="~.(T34$r)^.(T34$p) )
#     
#     T34$data %>% 
#         ggplot(aes(root_length, nbt_intensity_per_area)) +
#         labs(
#             subtitle = paste0("34&deg;C &minus; DAT", dat),
#             x = "Root length (mm)", 
#             y = "Average NBT intensity") +
#         geom_point(color = "dodgerblue") +
#         geom_smooth(method = "lm", se = FALSE, color = "navyblue", alpha = 0.7) +
#         annotate(
#             geom = "text",
#             size = 8,
#             x = 45,
#             y = 216,
#             label = list(T34$anno),
#             parse = TRUE
#         ) +
#         scale_x_continuous(limits = c(0, 90), breaks = seq(0, 90, 30)) +
#         scale_y_continuous(limits = c(160, 220)) +
#         theme(title = element_markdown())
#     
#     ggsave(
#         filename = sprintf("cor_T34_DAT%s.jpeg", dat),
#         path = "./",
#         device = "jpeg",
#         units = "cm",
#         dpi = 660,
#         height = 12,
#         width = 17
#     )
# }
# 
# 
# # T38 ====
# for (dat in unique(df0$DAT)){
#     cor_group <- paste(dat, "38", sep = " - ")
#     T38 <- list(
#         data = df0 %>% filter(DAT == dat, temperature == 38),
#         r = round((corr_df %>% filter(Group == cor_group))$r, 2),
#         p = num2asterisk((corr_df %>% filter(Group == cor_group))$p)
#     )
#     T38$anno <- sprintf("r = %s<sup>%s</sup>", T38$r, T38$p)
#     
#     T38$data %>% 
#         ggplot(aes(root_length, nbt_intensity_per_area)) +
#         labs(
#             title = paste0("38&deg;C &minus; DAT", dat, "; ", T38$anno),
#             x = "Root length (mm)", 
#             y = "Average NBT intensity") +
#         geom_point(color = "maroon") +
#         geom_smooth(method = "lm", se = FALSE, color = "maroon4", alpha = 0.7) +
#         # annotate(
#         #     geom = "text",
#         #     size = 8,
#         #     x = 25,
#         #     y = 120,
#         #     label = list(T38$anno),
#         #     parse = TRUE
#         # ) +
#         # scale_x_continuous(limits = c(0, 90), breaks = seq(0, 90, 30)) +
#         # scale_y_continuous(limits = c(0, 220)) +
#         theme( 
#             title = element_markdown()
#         )
#     
#     ggsave(
#         filename = sprintf("cor_T38_DAT%s.jpeg", dat),
#         path = "./",
#         device = "jpeg",
#         units = "cm",
#         dpi = 660,
#         height = 12,
#         width = 17
#     )
# }
# 
# 
# # Comparison ====
# shapiro.test(filter(df0, temperature == 38)$nbt_intensity_per_area)
# 
# df0 %>% 
#     ggplot(aes(group, nbt_intensity_per_area)) +
#     theme_bw() +
#     labs(
#         x = "Temperature (&deg;C)", 
#         y = "Average NBT intensity"
#     ) +
#     geom_point() +
#     geom_boxplot() +
#     geom_signif(
#         test = "wilcox.test",
#         comparisons = list(c("34_5", "38_5")),
#         test.args = list(exact = FALSE),
#         y_position = 250,
#         tip_length = c(0.1, 0.25)
#     ) +
#     scale_y_continuous(limits = c(80, 280)) +
#     theme(
#         text = element_text(family = "sans", face = "bold", size = 22),
#         title = element_markdown(),
#         axis.title.y.left = element_text(margin = ggplot2::margin(r = 9)),
#         axis.title.x.bottom = element_text(margin = ggplot2::margin(t = 7)),
#     )
# 
# ggsave(
#     filename = "T34-vs-T38.jpeg",
#     path = "./",
#     device = "jpeg",
#     units = "cm",
#     dpi = 660,
#     height = 12,
#     width = 17
# )























