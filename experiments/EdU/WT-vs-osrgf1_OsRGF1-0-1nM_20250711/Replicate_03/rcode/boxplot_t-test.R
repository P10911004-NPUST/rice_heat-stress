suppressMessages({
    rm(list = ls())
    if ( ! is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    source("C:/jklai/github/plotools/R/num2asterisk.R")
    
    hline_grob <- function(xmin, xmax, y){
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = 2)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../OUT_EdU_Replicate_03.xlsx")

df0 <- rawdata %>%
    dplyr::filter(
        ! str_detect(img_name, "cancel"),
        ! str_detect(note, "discard")
    ) %>% 
    dplyr::mutate(
        genotype = str_replace(img_name, "DAI07_(WT|M07|M08)_.*", "\\1"),
        treatment = str_replace(img_name, ".*_(\\d{1,4})pM_.*", "\\1"),
        distance = distance_from_root_tip_pixels * `resolution (um/pixel)`,
        group = paste(genotype, treatment, sep = "_")
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(total_intensity),
        .by = "group"
    ) %>% 
    dplyr::filter(
        ! is_outlier,
        treatment %in% c("0", "1000")
    )

df0$group <- factor(
    df0$group, 
    levels = c("WT_0", "WT_1000", "M07_0", "M07_1000", "M08_0", "M08_1000")
)

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Distance from root tip ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
out <- oneway_test(df0, distance ~ group)
out$tests
cld <- out$cld
cld$y_pos <- estimate_cld_pos(cld$MAX)

ggplot(df0, aes(group, distance, color = treatment)) +
    theme_classic() +
    labs(
        y = "Distance from<br>root tip (<i>&micro;</i>m)"
    ) +
    geom_boxplot(outliers = FALSE) +
    geom_point(
        size = 4,
        alpha = 0.3,
        position = position_jitter(width = 0.1)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, y_pos + 30, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(300, 1200), breaks = seq(300, 1200, 300)) +
    scale_x_discrete(
        labels = c("WT", "", "<i>osrgf1-7</i>", "", "<i>osrgf1-8</i>", "")
    ) +
    scale_color_manual(
        values = c("#000000", "#D55E00"),
        labels = c("Mock", "1 nM OsRGF1")
    ) +
    hline_grob(1 - 0.3, 2 + 0.3, 300 - 30) +
    hline_grob(3 - 0.3, 4 + 0.3, 300 - 30) +
    hline_grob(5 - 0.3, 6 + 0.3, 300 - 30) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 24),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(size = 22, hjust = c(-.5, 0, .2, 0, .2, 0)),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        legend.title = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.direction = "horizontal",
        legend.key.spacing.x = grid::unit(0.05, "npc")
    )

ggsave(
    filename = "distance_from_root_tip.jpg",
    path = "./figures",
    create.dir = TRUE,
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 11,
    width = 17
)


# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# # Total EdU intensity ====
# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# df0 <- df0 %>% 
#     dplyr::mutate(
#         is_outlier = Grubbs_test(total_intensity),
#         .by = group
#     ) %>% 
#     dplyr::filter( ! is_outlier )
# 
# out <- oneway_test(df0, total_intensity ~ group)
# out$tests
# cld <- out$cld
# cld$y_pos <- estimate_cld_pos(cld$MAX)
# 
# ggplot(df0, aes(group, total_intensity, color = treatment)) +
#     theme_classic() +
#     labs(
#         y = "Total EdU intensity (AU)"
#     ) +
#     geom_boxplot(outliers = FALSE) +
#     geom_point(
#         size = 4,
#         alpha = 0.3,
#         position = position_jitter(width = 0.1)
#     ) +
#     geom_text(
#         inherit.aes = FALSE,
#         data = cld,
#         mapping = aes(GROUP, y_pos + 30, label = CLD),
#         size = 8
#     ) +
#     # scale_y_continuous(limits = c(300, 1200), breaks = seq(300, 1200, 300)) +
#     scale_x_discrete(
#         labels = c("WT", "", "<i>osrgf1-7</i>", "", "<i>osrgf1-8</i>", "")
#     ) +
#     scale_color_manual(
#         values = c("#000000", "#D55E00"),
#         labels = c("Mock", "1 nM OsRGF1")
#     ) +
#     hline_grob(1 - 0.3, 2 + 0.3, 300 - 30) +
#     hline_grob(3 - 0.3, 4 + 0.3, 300 - 30) +
#     hline_grob(5 - 0.3, 6 + 0.3, 300 - 30) +
#     theme(
#         text = element_text(family = "sans", face = "bold", size = 24),
#         axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
#         axis.title.x.bottom = element_blank(),
#         axis.text.x.bottom = element_markdown(size = 22, hjust = c(-.5, 0, .2, 0, .2, 0)),
#         axis.line.x.bottom = element_blank(),
#         axis.ticks.x.bottom = element_blank(),
#         legend.title = element_blank(),
#         legend.position = "inside",
#         legend.position.inside = c(0.5, 0.95),
#         legend.direction = "horizontal",
#         legend.key.spacing.x = grid::unit(0.05, "npc")
#     )
# 
# ggsave(
#     filename = "total_EdU_intensity.jpg",
#     path = "./figures",
#     create.dir = TRUE,
#     device = "jpeg",
#     dpi = 660,
#     units = "cm",
#     height = 11,
#     width = 17
# )
