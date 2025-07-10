suppressMessages({
    rm(list = ls())
    if (!is.null(dev.list())) dev.off()
    set.seed(1)
    
    if (!require(tidyverse)) install.packages("tidyverse")
    if (!require(ggtext)) install.packages("ggtext")
    if (!require(devtools)) install.packages("devtools")
    if (!require(statool)) devtools::install_github("P10911004-NPUST/statool", upgrade = "always")
    
    source("C:/jklai/github/plotools/R/utils4ggplot.R")
    
    heatmap_gradient <- function(
        n_breaks = 30,
        color_set = c("#1d3557", "#e63946")
    ){
        colorRampPalette(color_set)(n_breaks)
    }
})

rawdata <- readxl::read_excel("../OUT_Magnif_32X.xlsx")

genotype <- c("WT", "M07", "M08")
treatment <- c("0", "1", "10", "100", "1000")
group_lvls <- paste(
    rep(genotype, each = length(treatment)), 
    rep(treatment, times = length(genotype)),
    sep = "_"
)

df0 <- rawdata %>% 
    dplyr::filter(
        !str_detect(img_name, "cancel")
    ) %>% 
    dplyr::mutate(
        nbt_intensity = nbt_intensity / 1e7,
        genotype = str_replace(img_name, ".*_(WT|M07|M08)_(.*)pM_.*", "\\1"),
        treatment = str_replace(img_name, ".*_(WT|M07|M08)_(.*)pM_.*", "\\2"),
        group = paste(genotype, treatment, sep = "_")
    )

df0$group <- factor(df0$group, levels = group_lvls)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# WT ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(genotype == "WT") 

# df1 <- df1 %>%
#     dplyr::mutate(
#         is_outlier = Grubbs_test(root_length, min_n = 5, iteration = 1),
#         .by = "group"
#     ) %>%
#      dplyr::filter(!is_outlier)

out <- oneway_test(df1, root_length ~ treatment)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df1, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI7, WT, seminal root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(outliers = FALSE, alpha = 0.3) +
    geom_point(alpha = 0.5, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD, color = GROUP),
        size = 8
    ) +
    scale_color_grey(start = .5, end = 0) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        axis.title.y.left = element_markdown(),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "none"
    )

ggsave(
    filename = "root_length_WT.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# M07 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(genotype == "M07")

# df1 <- df1 %>% 
#     dplyr::mutate(
#         is_outlier = Grubbs_test(root_length, min_n = 5, iteration = 1),
#         .by = "group"
#     ) %>% 
    # dplyr::filter(!is_outlier)

out <- oneway_test(df1, root_length ~ treatment)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df1, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI7, <i>osrgf1-7</i>, seminal root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(alpha = 0.3) +
    geom_point(alpha = 0.5, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD, color = GROUP),
        size = 8
    ) +
    scale_color_grey(start = .5, end = 0) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        axis.title.y.left = element_markdown(),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "none"
    )

ggsave(
    filename = "root_length_M07.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# M08 ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(genotype == "M08")

# df1 <- df1 %>% 
#     dplyr::mutate(
#         is_outlier = Grubbs_test(nbt_intensity, min_n = 5, iteration = 1),
#         .by = "group"
#     ) %>% 
#     dplyr::filter(!is_outlier)

out <- oneway_test(df1, root_length ~ treatment)
out$tests
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)
cld

ggplot(df1, aes(treatment, root_length, color = treatment)) +
    theme_bw() +
    labs(
        subtitle = "Gel system, DAI7, <i>osrgf1-8</i>, seminal root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)"
    ) +
    geom_boxplot(alpha = 0.3) +
    geom_point(alpha = 0.5, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD, color = GROUP),
        size = 8
    ) +
    scale_color_grey(start = .5, end = 0) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        axis.title.y.left = element_markdown(),
        plot.subtitle = element_markdown(size = 18),
        legend.position = "none"
    )

ggsave(
    filename = "root_length_M08.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# WT vs M08 ====
## Mock vs 1 nM ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
df1 <- df0 %>% 
    dplyr::filter(
        genotype != "M07",
        treatment %in% c("0", "1000"),
    )

out <- oneway_test(df1, root_length ~ group)
out$tests
out$pre_hoc
cld <- out$cld
cld$cld_pos <- estimate_cld_pos(cld$MAX)

ggplot(df1, aes(group, root_length, color = treatment)) +
    theme_classic() +
    labs(
        subtitle = "Gel system, DAI7, WT & <i>osrgf1-8</i>, seminal root",
        x = "OsRGF1 (pM)",
        y = "Root length (mm)",
        color = "OsRGF1 (nM)"
    ) +
    geom_boxplot(alpha = 0.7) +
    geom_point(alpha = 0.7, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, cld_pos, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(35, 85)) +
    scale_x_discrete(
        labels = c(
            "", "WT",
            "", "<i>osrgf1-8</i>"
        )
    ) +
    scale_color_manual(
        values = heatmap_gradient(n_breaks = 5),
        labels = c("Mock", "1 nM OsRGF1")
    ) +
    hline_grob(1 - .3, 2 + .3, 33) +
    hline_grob(3 - .3, 4 + .3, 33) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 22),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.title.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        axis.line.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(hjust = c(0, 2.2, 0, 1.2)),
        plot.subtitle = element_markdown(size = 14),
        legend.position = "top",
        legend.title = element_blank(),
        legend.key.spacing.x = ggplot2::unit(1, "cm"),
        legend.key.size = unit(x = 0.7, units = "cm")
    )

ggsave(
    filename = "root_length_WT-M08.jpg",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)
