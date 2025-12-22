rm(list = ls())
if (!is.null(dev.list())) dev.off()
set.seed(1)

suppressPackageStartupMessages({
    library(tidyverse)
    library(ggtext)
    library(ggsignif)
    library(statool)
    
    hline_grob <- function(xmin, xmax, y, linewidth = 1.5) {
        ggplot2::annotation_custom(
            grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
            xmin = xmin, 
            xmax = xmax, 
            ymin = y, 
            ymax = y
        )
    }
})

rawdata <- readxl::read_excel("../../OUT_NBT.xlsx")

df0 <- rawdata %>% 
    dplyr::filter(str_detect(img_name, "cancel", negate = TRUE)) %>% 
    dplyr::mutate(
        nbt_total = nbt_total / 1e6,
        genotype = factor(genotype, levels = c("WT", "osrgf1-7")),
        heat = factor(paste0("T", heat), levels = c("T30", "T40")),
        RGF1 = factor(RGF1, levels = c(0, 1)),
        group = paste(genotype, heat, RGF1, sep = "_")
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(root_length),
        .by = group
    ) %>% 
    dplyr::filter(!is_outlier)

df0$group <- factor(
    df0$group, 
    levels = c("WT_T30_0", "osrgf1-7_T30_0", "WT_T40_0", "osrgf1-7_T40_0",
               "WT_T30_1", "osrgf1-7_T30_1", "WT_T40_1", "osrgf1-7_T40_1")
)

write.csv(df0, "./figure/root_length.csv", row.names = FALSE)

for (g in unique(df0$group)) {
    df_tmp <- dplyr::filter(df0, group == g)
    print(paste0(g, ": ", is_normality(df_tmp$root_length)))
}

ggplot(df0, aes(group, root_length, color = heat)) +
    theme_classic() +
    labs(
        y = "Seminal root length (mm)"
    ) +
    geom_boxplot(
        outliers = FALSE
    ) +
    geom_point(
        mapping = aes(shape = genotype),
        size = 4,
        alpha = 0.5,
        position = position_jitter(width = 0.1, seed = 1)
    ) +
    ggsignif::geom_signif(
        test = "t.test",
        comparisons = list(
            c("WT_T30_0", "osrgf1-7_T30_0"),
            c("WT_T40_0", "osrgf1-7_T40_0"),
            c("WT_T30_1", "osrgf1-7_T30_1"),
            c("WT_T40_1", "osrgf1-7_T40_1")
        ),
        y_position = c(84, 93, 83, 93),
        tip_length = c(
            0.05, 0.05,
            0.25, 0.05,
            0.05, 0.05,
            0.05, 0.05
        ),
        map_signif_level = pval2asterisk,
        textsize = 8,
        fontface = "bold",
        vjust = -0.3,
        color = "black"
    ) +
    scale_y_continuous(limits = c(50, 100)) +
    scale_x_discrete(
        labels = c("", "Mock", "", "",
                   "", "1 nM OsRGF1", "", "")
    ) +
    scale_color_manual(
        values = c("#0072B2", "#D55E00"),
        labels = c("30&deg;C", "40&deg;C"),
        guide = guide_legend(
            order = 1
        )
    ) +
    scale_shape_manual(
        values = c("circle", "diamond open"),
        labels = c("WT", "<i>osrgf1-7</i>"),
        guide = guide_legend(
            override.aes = list(size = 4),
            order = 2
        )
    ) +
    hline_grob(1 - 0.3, 4 + 0.3, 50) +
    hline_grob(5 - 0.3, 8 + 0.3, 50) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 25,
            hjust = c(0, 0.1, 0, 0, 0, 0.35, 0, 0)
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        
        axis.title.y.left = element_markdown(
            lineheight = 1.05,
            margin = ggplot2::margin(r = 9)
        ),
        legend.position = "top",
        legend.position.inside = c(0.5, 0.95),
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 23, margin = margin(r = 6, l = 6)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 1
    )

ggsave(
    filename = "root_length.jpg",
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 17
)

out <- oneway_test(df0, nbt_total ~ group)
out$tests
cld <- out$cld
cld[order(cld$GROUP), ]
cld$YPOS_MAX <- estimate_cld_pos(cld$MAX) + 2


# ggplot(df0, aes(group, nbt_total, color = heat)) +
#     theme_classic() +
#     labs(
#         y = "Total NBT intensity<br>(10<sup>6</sup> AU)"
#     ) +
#     geom_boxplot(
#         outliers = FALSE
#     ) +
#     geom_point(
#         mapping = aes(shape = genotype),
#         size = 4,
#         alpha = 0.5,
#         position = position_jitter(width = 0.1, seed = 1)
#     ) +
#     geom_text(
#         inherit.aes = FALSE,
#         data = cld,
#         mapping = aes(GROUP, YPOS_MAX, label = CLD),
#         size = 8
#     ) +
#     scale_y_continuous(limits = c(0, 40)) +
#     scale_x_discrete(
#         labels = c("", "Mock", "", "",
#                    "", "1 nM OsRGF1", "", "")
#     ) +
#     scale_color_manual(
#         values = c("#0072B2", "#D55E00"),
#         labels = c("30&deg;C", "40&deg;C"),
#         guide = guide_legend(
#             order = 1
#         )
#     ) +
#     scale_shape_manual(
#         values = c("circle", "diamond open"),
#         labels = c("WT", "osrgf1-7"),
#         guide = guide_legend(
#             override.aes = list(size = 4),
#             order = 2
#         )
#     ) +
#     hline_grob(1 - 0.3, 4 + 0.3, 0) +
#     hline_grob(5 - 0.3, 8 + 0.3, 0) +
#     theme(
#         text = element_text(family = "sans", face = "bold", size = 27),
#         
#         axis.title.x.bottom = element_blank(),
#         axis.text.x.bottom = element_markdown(
#             size = 25,
#             hjust = c(0, 0.1, 0, 0, 0, 0.35, 0, 0)
#         ),
#         axis.line.x.bottom = element_blank(),
#         axis.ticks.x.bottom = element_blank(),
#         
#         axis.title.y.left = element_markdown(
#             lineheight = 1.05,
#             margin = ggplot2::margin(r = 9)
#         ),
#         
#         legend.position = "top",
#         legend.position.inside = c(0.5, 0.95),
#         legend.background = element_blank(),
#         legend.direction = "horizontal",
#         legend.box = "horizontal",
#         legend.title = element_blank(),
#         legend.text = element_markdown(
#             family = "sans", face = "plain", size = 23, margin = margin(r = 6, l = 6)
#         ),
#         legend.key.size = grid::unit(x = 0.04, units = "npc"),
#         legend.justification.top = 1
#     )
# 
# ggsave(
#     filename = "nbt_total.jpg",
#     path = "./figure/",
#     device = "jpeg",
#     dpi = 660,
#     units = "cm",
#     height = 13,
#     width = 17
# )
