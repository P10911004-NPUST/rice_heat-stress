suppressMessages({
    rm(list = ls())
    if ( ! is.null(dev.list())) dev.off()
    set.seed(1)
    
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
})

hline_grob <- function(xmin, xmax, y, linewidth = 1.5){
    ggplot2::annotation_custom(
        grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
        xmin = xmin, 
        xmax = xmax, 
        ymin = y, 
        ymax = y
    )
}

group_lvls <- c("WT_0", "WT_1", "osrgf1-7_0", "osrgf1-7_1")

rawdata <- readxl::read_excel("./osrgf1_EdU.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(
        ! str_detect(img_name, "cancel"),
        note != "discard"
    ) %>% 
    dplyr::mutate(
        distance = distance_from_root_tip_pixels * `resolution (um/pixel)`,
        treatment = factor(`OsRGF1 treatment (nM)`, levels = c(0, 1)),
        group = factor(paste(genotype, treatment, sep = "_"), levels = group_lvls)
    ) 

df0 <- df0 %>% 
    dplyr::mutate(is_outlier = Grubbs_test(distance), .by = "group") %>% 
    dplyr::filter( ! is_outlier )

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Distance from root tip (microns) ====
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
out <- oneway_test(df0, distance ~ group)
out$tests
cld <- out$cld
cld
cld$y_pos <- estimate_cld_pos(cld$MAX)

ggplot(df0, aes(group, distance, color = treatment)) +
    theme_classic() +
    labs(
        y = "Distance from<br>root tip (<i>&micro;</i>m)",
        color = "OsRGF1 (nM)"
    ) +
    geom_boxplot(outliers = FALSE) +
    geom_point(size = 4, alpha = 0.3, position = position_jitter(width = 0.1)) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, y_pos + 50, label = CLD),
        size = 8
    ) +
    scale_y_continuous(limits = c(300, 1100), breaks = seq(300, 1100, 200)) +
    scale_x_discrete(
        labels = c("WT", "", "<i>osrgf1-7</i>", "")
    ) +
    scale_color_manual(
        values = c("#000000", "#CC79A7"),
        labels = c("Mock", "1 nM OsRGF1")
    ) +
    hline_grob(xmin = 1 - 0.3, xmax = 2 + 0.3, y = 300 - 30) +
    hline_grob(xmin = 3 - 0.3, xmax = 4 + 0.3, y = 300 - 30) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 24),
        axis.title.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
        axis.text.x.bottom = element_markdown(size = 22, hjust = c(-1.2, 0, -0.1, 0)),
        axis.ticks.x.bottom = element_blank(),
        axis.line.x.bottom = element_blank(),
        legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.position = "inside",
        legend.position.inside = c(0.5, 0.95),
        legend.key.height = ggplot2::unit(0.07, "npc"),
        legend.key.spacing.x = ggplot2::unit(0.05, "npc")
    )

ggsave(
    filename = "osrgf1_EdU.jpg",
    path = "../figures",
    device = "jpeg",
    units = "cm",
    dpi = 660,
    height = 11,
    width = 17
)

# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# # Total intensity ====
# #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# out <- oneway_test(df0, total_intensity ~ group)
# out$tests
# cld <- out$cld
# cld
# cld$y_pos <- estimate_cld_pos(cld$MAX)
# 
# ggplot(df0, aes(group, total_intensity, color = treatment)) +
#     theme_classic() +
#     labs(
#         y = "Total EdU intensity",
#         color = "OsRGF1 (nM)"
#     ) +
#     geom_boxplot() +
#     geom_point(position = position_jitter(width = 0.1)) +
#     geom_text(
#         inherit.aes = FALSE,
#         data = cld,
#         mapping = aes(GROUP, y_pos, label = CLD),
#         size = 8
#     ) +
#     # scale_y_continuous(limits = c(200, 1200), breaks = seq(200, 1200, 200)) +
#     theme(
#         text = element_text(family = "sans", face = "bold", size = 22),
#         axis.title.x.bottom = element_blank(),
#         axis.title.y.left = element_markdown(margin = ggplot2::margin(r = 9)),
#         legend.direction = "horizontal",
#         legend.position = "inside",
#         legend.position.inside = c(0.5, 0.95)
#     )
