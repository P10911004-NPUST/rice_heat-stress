rm(list = ls())
if (!is.null(dev.list())) dev.off()

library(tidyverse)
library(ggtext)
library(ggsignif)
library(statool)
library(outlying)

hline_grob <- function(xmin, xmax, y, linewidth = 1.5) {
    ggplot2::annotation_custom(
        grob = grid::linesGrob(gp = grid::gpar(lwd = linewidth)),
        xmin = xmin, 
        xmax = xmax, 
        ymin = y, 
        ymax = y
    )
}

rawdata <- readxl::read_excel("../../OUT_EdU.xlsx")

grp_lvl <- c("WT_Mock", "WT_Est", "OE7_Mock", "OE7_Est", "OE28_Mock", "OE28_Est")

rep <- 1

df0 <- rawdata %>% 
    dplyr::mutate(
        treatment = case_when(Est_uM == 0 ~ "Mock", 
                              Est_uM > 0 ~ "Est"),
        grp = paste(genotype, treatment, sep = "_"),
        val = distance_from_root_tip_um
    ) %>% 
    dplyr::mutate(
        genotype = factor(genotype, levels = c("WT", "OE7", "OE28")),
        treatment = factor(treatment, levels = c("Mock", "Est")),
        grp = factor(grp, levels = grp_lvl)
    ) %>% 
    dplyr::mutate(
        is_outlier = Grubbs_test(val),
        .by = "grp"
    ) %>% 
    dplyr::filter(
        note != "discard",
        !is_outlier
    ) %>% 
    dplyr::select(genotype, treatment, grp, val)

is_normality(df0, val ~ grp)
out <- oneway_test(df0, val ~ grp)
print(out$tests)
cld <- out[["cld"]]
print(cld)
cld <- cld %>% 
    dplyr::mutate(
        YPOS_MAX = estimate_cld_pos(MAX),
        YPOS_MIN = MIN - 100,
        genotype = str_replace(GROUP, "(.*)_(.*)", "\\1"),
        treatment = str_replace(GROUP, "(.*)_(.*)", "\\2")
    )

ggplot(df0, aes(grp, val, color = treatment)) +
    theme_classic() +
    labs(y = "Distance of EdU signal<br>localization (<i>&micro;</i>m)") +
    geom_boxplot(
        outliers = FALSE,
        outlier.shape = NA
    ) +
    geom_point(
        position = position_jitter(width = 0.1, seed = 1),
        size = 4,
        alpha = 0.5
    ) +
    ggsignif::geom_signif(
        comparisons = list(
            c("WT_Est", "WT_Mock"),
            c("OE7_Est", "OE7_Mock"),
            c("OE28_Est", "OE28_Mock")
        ),
        color = "black",
        map_signif_level = pval2asterisk,
        fontface = "bold",
        textsize = 8,
        vjust = -0.3,
        y_position = c(800, 1250, 1150),
        tip_length = c(0.05, 0.05, 0.05, 0.7, 0.05, 0.6)
    ) +
    geom_text(
        inherit.aes = FALSE,
        data = cld,
        mapping = aes(GROUP, YPOS_MIN, color = treatment, label = N),
        size = 7,
        show.legend = FALSE
    ) +
    scale_x_discrete(
        labels = c("WT", "", "OE7", "", "OE28", "")
    ) +
    scale_y_continuous(limits = c(200, 1400), breaks = seq(200, 1400, 200)) +
    scale_color_manual(
        labels = c("Mock", "<i>&beta;</i>-Estradiol"),
        values = c("#56B4E9", "#CC79A7"),
        guide = guide_legend(
            order = 1
        )
    ) +
    hline_grob(1 - 0.3, 2 + 0.3, 200 - 50) +
    hline_grob(3 - 0.3, 4 + 0.3, 200 - 50) +
    hline_grob(5 - 0.3, 6 + 0.3, 200 - 50) +
    theme(
        text = element_text(family = "sans", face = "bold", size = 27),
        
        axis.title.x.bottom = element_blank(),
        axis.text.x.bottom = element_markdown(
            size = 27,
            hjust = c(-0.23, 0, -0.05, 0, 0.07, 0),
            margin = ggplot2::margin(t = 11),
            lineheight = 1.2
        ),
        axis.line.x.bottom = element_blank(),
        axis.ticks.x.bottom = element_blank(),
        axis.title.y.left = element_markdown(
            lineheight = 1.2,
            margin = ggplot2::margin(r = 11)
        ),
        legend.position = "top",
        legend.position.inside = c(0.5, 0.95),
        legend.background = element_blank(),
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = element_blank(),
        legend.text = element_markdown(
            family = "sans", face = "plain", size = 23, margin = margin(r = 9, l = 9)
        ),
        legend.key.size = grid::unit(x = 0.04, units = "npc"),
        legend.key.spacing.x = grid::unit(x = 0.04, units = "npc"),
        legend.justification.top = 0
    )

ggsave(
    filename = sprintf("EdU_rep%.02d.jpg", rep),
    path = "./figure/",
    device = "jpeg",
    dpi = 660,
    units = "cm",
    height = 14,
    width = 17
)
